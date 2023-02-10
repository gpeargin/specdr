#' Detect Change for a Single Pixel with Linear Regression of a Harmonic Function
#'
#' This function is based on the CCDC algorithm developed by Zhu, et al. (2014). A linear model of the form
#' \deqn{\hat{y} = \beta _{0}\ +\ \beta _{1}sin(\frac{2\pi}{365}t)\ +\ \beta _{2}cos(\frac{2\pi}{365}t)\ +\ \beta _{3}t,\quad t\ =\ Julian\ date}
#' is iteratively fitted to the time series of a pixel's values; its second and third (harmonic) terms model seasonal fluctuations, while its last term captures long-term trends.
#' After an initial model is fit, future observations are compared against their predicted values, and a new model is fit once residuals consistently exceed a threshold.
#' This is then recorded as a change, and the process repeats itself until the end of the time series is reached.\cr
#' \cr
#' This function differs from typical CCDC implementations in three ways:
#' \enumerate{
#' \item In addition to the root mean square error, the user also has the option to use a Z-score or the interquartile range to flag observations as potential change.
#' \item Instead of depending on a fixed number of observations, fitting and flagging are done with however many observations fall within a time window.
#' Similarly, change detection does not depend on consecutive flags, but on what fraction of the observations falling within a time window are flagged.
#' \item While CCDC looks at the average residual across six time series to determine whether a change has occurred, this function takes only one time series as input, allowing for change detection of individual bands or band indices.
#'}
#' @param vals Vector containing the observed values of the time series.
#' @param t.Gregorian Vector of dates associated with the time series values. Use %Y-%m-%d format.
#' @param t.fit Time window used to fit new models, expressed in number of (whole) days. All observations occurring in this time window will be used when fitting a new model, with the first day being that of the first observation. Thus, the actual number of days added to the first is `t.fit - 1`.
#' @param t.flag Time window used for determining change; format is the same as `t.fit`. A change will be recorded if the ratio of flagged observations to all observations occurring in this window exceeds `pct.flag`. Smaller `t.flag` values will lead to models better suited for capturing short-lived changes or detecting changes in real time, but will be less robust to noise.
#' @param pct.flag Fraction of observations occuring in `t.flag` that must be flagged in order for a change to be recorded.
#' @param first.half Fraction of flagged observations that must occur in the first half of `t.flag` for a change to be recorded. Helps ensure changes aren't recorded prematurely. Must be between 0 and 0.5.
#' @param flag.stat Statistic to be used to flag observations. Options are "rmse" for the root mean square error, "iqr" for the interquartile range, or "z" for the normal Z-score.
#' @param c Constant that controls the `flag.stat` threshold value. Used as a scalar for multiplication if "rmse" or "iqr" is chosen as `flag.stat`, and as a lower-tail p-value if `flag.stat` is "z." Equations for the threshold values are as follows:
#' \enumerate{
#' \item{RMSE}{\deqn{(y - \hat{y})^{\ast} \geq c * \sqrt{\frac{1}{n}\sum_{i=1}^{n}\ (y_{i} - \hat{y}_{i})^{2}}}}
#' \item{IQR}{\deqn{(y - \hat{y})^{\ast} < Q_{1,\ y - \hat{y}} - c * IQR_{y - \hat{y}}\quad or}\cr\deqn{\quad (y - \hat{y})^{\ast} > Q_{3,\ y - \hat{y}} + c * IQR_{y - \hat{y}}}}
#' \item{Z-score}{\deqn{(y - \hat{y})^{\ast} \geq \left | Z_{c}\sigma_{y-\hat{y}}+\mu_{y-\hat{y}}{} \right |, }\cr where \eqn{Z_{c}} is produced by the inverse CDF of the normal distribution \deqn{\Phi^{-1}(\frac{c + 1}{2})}}
#' }
#' If `NULL`, `c` will default to 3 for "rmse," 1.5 for "iqr," and .005 for "z."
#'
#'
#' @return A list containing the dates of changes, their indices within the time series, and the coefficients of each model.
#' @source Zhe Zhu, Curtis E. Woodcock, Continuous change detection and classification of land cover using all available Landsat data, Remote Sensing of Environment, Volume 144, 2014, Pages 152-171, ISSN 0034-4257, \href{https://doi.org/10.1016/j.rse.2014.01.011}{https://doi.org/10.1016/j.rse.2014.01.011}.
#' @export
#'
#' @examples
#' #load data
#' data(ts_ex)
#' data(tg_ex)
#'
#' #changes are:
#' #1. tg_ex[101] (increase in mean)
#' #2. tg_ex[201] (decrease in mean)
#' plot(tg_ex, ts_ex)
#'
#' #fit models
#' changes_rmse <- detect.change.harmonic(ts_ex, tg_ex)
#' changes_iqr <- detect.change.harmonic(ts_ex, tg_ex, flag.stat = "iqr")
#' changes_z <- detect.change.harmonic(ts_ex, tg_ex, flag.stat = "z")
#'
#' #check results
#' print("RMSE")
#' changes_rmse
#' print("IQR")
#' changes_iqr
#' print("Z")
#' changes_z
detect.change.harmonic <-
  function(vals,
           t.Gregorian,
           t.fit = 365,
           t.flag = 365,
           pct.flag = 0.9,
           first.half = 0,
           flag.stat = "rmse",
           c = NULL) {
    t.fit <- lubridate::days(t.fit - 1)
    t.flag <- lubridate::days(t.flag - 1)
    t.start <- t.Gregorian[1]
    df <- data.frame(
      vals = vals,
      t.Gregorian = t.Gregorian,
      t.Julian = julian(t.Gregorian, origin = as.Date(paste0(
        lubridate::year(t.start), "-01-01"
      )))
    )
    changes <- vector()
    coefs <- list()
    i <- 1

    while (t.start < t.Gregorian[length(t.Gregorian)]) {
      model <-
        stats::glm(
          vals ~ sinpi(2 / 365 * t.Julian) + cospi(2 / 365 * t.Julian) + t.Julian,
          data = df,
          subset = t.Gregorian >= t.start &
            t.Gregorian <= t.start + t.fit
        )
      coefs[[length(coefs) + 1]] <- model$coefficients
      if (t.start + t.fit < t.Gregorian[length(t.Gregorian)]) {
        preds <- stats::predict.glm(model, newdata = df)
        res <-
          vals - preds
        if (flag.stat == "rmse") {
          if (is.null(c)) {
            c <- 3
          }
          rmse.res <- sqrt(mean(res[which(t.Gregorian >= t.start &
                                            t.Gregorian <= t.start + t.fit)] ** 2, na.rm = TRUE))
          flags <- which(res >= c * rmse.res)
        }
        else if (flag.stat == "iqr") {
          if (is.null(c)) {
            c <- 1.5
          }
          iqr.res <-
            stats::IQR(res[which(t.Gregorian >= t.start &
                                   t.Gregorian <= t.start + t.fit)], na.rm = TRUE)
          q1.res <-
            stats::quantile(res[which(t.Gregorian >= t.start &
                                        t.Gregorian <= t.start + t.fit)], 0.25, na.rm = TRUE)
          q3.res <-
            stats::quantile(res[which(t.Gregorian >= t.start &
                                        t.Gregorian <= t.start + t.fit)], 0.75, na.rm = TRUE)
          flags <-
            which(res < q1.res - c * iqr.res |
                    res > q3.res + c * iqr.res)
        }
        else if (flag.stat == "z") {
          if (is.null(c)) {
            c <- .005
          }
          mu.res <-
            mean(res[which(t.Gregorian >= t.start &
                             t.Gregorian <= t.start + t.fit)], na.rm = TRUE)
          sigma.res <-
            stats::sd(res[which(t.Gregorian >= t.start &
                                  t.Gregorian <= t.start + t.fit)], na.rm = TRUE)
          z.res <-
            (res - mu.res) / sigma.res
          flags <- which(abs(z.res) >= abs(stats::qnorm(c)))
        }
        else{
          stop("flag.stat missing or invalid, choose 'rmse', 'iqr', or 'z'")
        }
        flags <-
          flags[which(flags %in% min(which(t.Gregorian >= t.start + t.fit)):length(vals))]
        if (length(flags) > 0 &
            t.Gregorian[flags[i]] + t.flag <= t.Gregorian[length(t.Gregorian)]) {
          while (t.Gregorian[flags[i]] + t.flag <= t.Gregorian[length(t.Gregorian)]) {
            if (first.half >= 0 && first.half <= 0.5) {
              condition <- length(flags[i]:max(flags <= max(
                which(t.Gregorian <= t.Gregorian[flags[i]] + t.flag)
              ))) >= floor(pct.flag * length(flags[i]:max(
                which(t.Gregorian <= t.Gregorian[flags[i]] + t.flag)
              ))) & length(flags[i]:max(flags <= max(which(
                t.Gregorian <= t.Gregorian[flags[i]] + floor(t.flag / 2)
              )))) >= floor(first.half * pct.flag * length(flags[i]:max(
                which(t.Gregorian <= t.Gregorian[flags[i]] + t.flag)
              )))
            }
            else{
              stop("first.half must be between 0 and 0.5")
            }
            if (condition) {
              changes[length(changes) + 1] <- flags[i]
              t.start <- t.Gregorian[flags[i]]
              i <- 1
              break
            }
            else{
              if (i == length(flags)) {
                t.start <- t.Gregorian[length(t.Gregorian)]
                break
              }
              i <- i + 1
              if (t.Gregorian[flags[i]] + t.flag > t.Gregorian[length(t.Gregorian)]) {
                t.start <- t.Gregorian[length(t.Gregorian)]
              }
            }
          }
        }
        else{
          t.start <- t.Gregorian[length(t.Gregorian)]
        }
      }
      else{
        break
      }
    }
    list_out <-
      list(
        change.dates = as.Date(c(NA, t.Gregorian[changes]), origin = "1970-01-01"),
        change.index = c(NA, changes),
        coefficients = coefs
      )
    return(list_out)
  }
