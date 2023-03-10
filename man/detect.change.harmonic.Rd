% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/detect_change_harmonic.R
\name{detect.change.harmonic}
\alias{detect.change.harmonic}
\title{Detect Change for a Single Pixel with Linear Regression of a Harmonic Function}
\source{
Zhe Zhu, Curtis E. Woodcock, Continuous change detection and classification of land cover using all available Landsat data, Remote Sensing of Environment, Volume 144, 2014, Pages 152-171, ISSN 0034-4257, \href{https://doi.org/10.1016/j.rse.2014.01.011}{https://doi.org/10.1016/j.rse.2014.01.011}.
}
\usage{
detect.change.harmonic(
  vals,
  t.Gregorian,
  t.fit = 365,
  t.flag = 365,
  pct.flag = 0.9,
  first.half = 0,
  flag.stat = "rmse",
  c = NULL
)
}
\arguments{
\item{vals}{Vector containing the observed values of the time series.}

\item{t.Gregorian}{Vector of dates associated with the time series values. Use \%Y-\%m-\%d format.}

\item{t.fit}{Time window used to fit new models, expressed in number of (whole) days. All observations occurring in this time window will be used when fitting a new model, with the first day being that of the first observation. Thus, the actual number of days added to the first is \code{t.fit - 1}.}

\item{t.flag}{Time window used for determining change; format is the same as \code{t.fit}. A change will be recorded if the ratio of flagged observations to all observations occurring in this window exceeds \code{pct.flag}. Smaller \code{t.flag} values will lead to models better suited for capturing short-lived changes or detecting changes in real time, but will be less robust to noise.}

\item{pct.flag}{Fraction of observations occuring in \code{t.flag} that must be flagged in order for a change to be recorded.}

\item{first.half}{Fraction of flagged observations that must occur in the first half of \code{t.flag} for a change to be recorded. Helps ensure changes aren't recorded prematurely. Must be between 0 and 0.5.}

\item{flag.stat}{Statistic to be used to flag observations. Options are "rmse" for the root mean square error, "iqr" for the interquartile range, or "z" for the normal Z-score.}

\item{c}{Constant that controls the \code{flag.stat} threshold value. Used as a scalar for multiplication if "rmse" or "iqr" is chosen as \code{flag.stat}, and as a lower-tail p-value if \code{flag.stat} is "z." Equations for the threshold values are as follows:
\enumerate{
\item{RMSE}{\deqn{(y - \hat{y})^{\ast} \geq c * \sqrt{\frac{1}{n}\sum_{i=1}^{n}\ (y_{i} - \hat{y}_{i})^{2}}}}
\item{IQR}{\deqn{(y - \hat{y})^{\ast} < Q_{1,\ y - \hat{y}} - c * IQR_{y - \hat{y}}\quad or}\cr\deqn{\quad (y - \hat{y})^{\ast} > Q_{3,\ y - \hat{y}} + c * IQR_{y - \hat{y}}}}
\item{Z-score}{\deqn{(y - \hat{y})^{\ast} \geq \left | Z_{c}\sigma_{y-\hat{y}}+\mu_{y-\hat{y}}{} \right |, }\cr where \eqn{Z_{c}} is produced by the inverse CDF of the normal distribution \deqn{\Phi^{-1}(\frac{c + 1}{2})}}
}
If \code{NULL}, \code{c} will default to 3 for "rmse," 1.5 for "iqr," and .005 for "z."}
}
\value{
A list containing the dates of changes, their indices within the time series, and the coefficients of each model.
}
\description{
This function is based on the CCDC algorithm developed by Zhu, et al. (2014). A linear model of the form
\deqn{\hat{y} = \beta _{0}\ +\ \beta _{1}sin(\frac{2\pi}{365}t)\ +\ \beta _{2}cos(\frac{2\pi}{365}t)\ +\ \beta _{3}t,\quad t\ =\ Julian\ date}
is iteratively fitted to the time series of a pixel's values; its second and third (harmonic) terms model seasonal fluctuations, while its last term captures long-term trends.
After an initial model is fit, future observations are compared against their predicted values, and a new model is fit once residuals consistently exceed a threshold.
This is then recorded as a change, and the process repeats itself until the end of the time series is reached.\cr
\cr
This function differs from typical CCDC implementations in three ways:
\enumerate{
\item In addition to the root mean square error, the user also has the option to use a Z-score or the interquartile range to flag observations as potential change.
\item Instead of depending on a fixed number of observations, fitting and flagging are done with however many observations fall within a time window.
Similarly, change detection does not depend on consecutive flags, but on what fraction of the observations falling within a time window are flagged.
\item While CCDC looks at the average residual across six time series to determine whether a change has occurred, this function takes only one time series as input, allowing for change detection of individual bands or band indices.
}
}
\examples{
#load data
data(ts_ex)
data(tg_ex)

#changes are:
#1. tg_ex[101] (increase in mean)
#2. tg_ex[201] (decrease in mean)
plot(tg_ex, ts_ex)

#fit models
changes_rmse <- detect.change.harmonic(ts_ex, tg_ex)
changes_iqr <- detect.change.harmonic(ts_ex, tg_ex, flag.stat = "iqr")
changes_z <- detect.change.harmonic(ts_ex, tg_ex, flag.stat = "z")

#check results
print("RMSE")
changes_rmse
print("IQR")
changes_iqr
print("Z")
changes_z
}
