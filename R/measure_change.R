#' Measure Detected Changes
#'
#' Calculates the raw and percent difference between model coefficients for changes detected by `detect.change` and stores them in a list.
#'
#' @param x A list created by `detect.change`.
#' @param t.Gregorian Vector of dates associated with the time series. Use %Y-%m-%d format.
#' @param t.sub Optional vector used to subset `t.Gregorian`. Should contain only a start and end index, i.e. `c(1,10)`.
#' @param filename Output file path. Valid extensions are .rdata, .rds, .json, and .yaml.
#'
#' @return Modifies the input list. `$dates` will be added to `x$info`; `$diff.raw` and `$diff.pct` will be added to `x$changes`. List elements corresponding to initial models are removed. If `t.sub` is not `NULL`, changes occurring outside of the subset will also be removed.
#' @importFrom rlist list.remove
#' @importFrom rlist list.save
#' @importFrom rlist list.stack
#' @export
#'
#' @examples
#' #load data
#' data(cl_ex)
#' data(tg_ex)
#'
#' #measure change for whole period
#' mc_ex <- measure.change(cl_ex, tg_ex)
#' mc_ex[[1]]$dates
#' head(rlist::list.stack(mc_ex[[2]]))
#'
#' #measure change for slice
#' mc_ex <- measure.change(cl_ex, tg_ex, c(50, 150))
#' mc_ex[[1]]$dates
#' head(rlist::list.stack(mc_ex[[2]]))

measure.change <-
  function(x,
           t.Gregorian,
           t.sub = NULL,
           filename = "") {
    change.table <- rlist::list.stack(x[[2]])
    init.mods <- which(is.na(change.table$change.index))
    new.mods <- which(!(1:nrow(change.table) %in% init.mods))
    change.table$diff.raw <- rep(NA, nrow(change.table))
    change.table$diff.raw[new.mods] <- lapply(new.mods, function(new.mods) change.table$coefficients[[new.mods]] - change.table$coefficients[[new.mods - 1]])
    change.table$diff.pct <- rep(NA, nrow(change.table))
    change.table$diff.pct[new.mods] <- lapply(new.mods, function(new.mods) change.table$diff.raw[[new.mods]] / change.table$coefficients[[new.mods - 1]])
    if (!is.null(t.sub)) {
      pos <- which(sapply(unique(change.table$position), function(i) any(change.table$change.index[which(change.table$position == i)] %in% t.sub[1]:t.sub[2])))
      change.table <- change.table[new.mods,][which(change.table[new.mods,]$position %in% pos & change.table[new.mods,]$change.index %in% t.sub[1]:t.sub[2]),]
      x[[1]]$dates <- list(From = t.Gregorian[t.sub[1]], To = t.Gregorian[t.sub[2]])
    }
    else{
      change.table <- change.table[new.mods,]
      x[[1]]$dates <- list(From = t.Gregorian[1], To = t.Gregorian[length(t.Gregorian)])
    }
    x[[2]] <- sapply(unique(change.table$position), function(i) list(change.table[which(change.table$position == i),]))
    return(x)
  }
