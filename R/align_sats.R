#' Align a Raster Time Series Stemming from Two Different Satellites
#'
#' Ensures that, on average, there will be no difference in mean or standard deviation between two overlapping raster time series obtained by different satellites.
#'
#' @param x Raster time series. Either a SpatRaster, a RasterStack, or a list of SpatRasters, RasterLayers, or file paths. The two time series must have same projection, extent, and resolution.
#' @param sat.order A vector denoting the satellite each raster stems from.
#' @param to.from Vector declaring which time series will be aligned with the other. The "from" series will be aligned with the "to" series. The elements of `to.from` must match the unique values of `sat.order`.
#' @param mean.only If `TRUE`, only the mean of the "from" series will change. If `FALSE`, both the mean and the standard deviation will be adjusted.
#' @param filename Output file path.
#' @param ... Additional arguments to pass to `writeRaster`.
#'
#' @return A SpatRaster of the aligned time series.
#' @import ggplot2
#' @export
#'
#' @examples
#' #load data
#' data(rts_ex)
#' data(so_ex)
#'
#' #before
#' avgs <- sapply(1:dim(rts_ex)[3], function(i) mean(rts_ex[,,i], na.rm = TRUE))
#' ggplot2::ggplot() +
#' ggplot2::geom_point(ggplot2::aes(x = 1:length(avgs), y = avgs, col = factor(so_ex)))
#'
#' #after
#' rts_ex <- align.sats(rast(rts_ex), so_ex, c("HLSL","HLSS"))
#' avgs <- sapply(1:dim(rts_ex)[3], function(i) mean(rts_ex[,,i], na.rm = TRUE))
#' ggplot2::ggplot() +
#' ggplot2::geom_point(ggplot2::aes(x = 1:length(avgs), y = avgs, col = factor(so_ex)))
align.sats <- function(x, sat.order, to.from, mean.only = FALSE, filename = "", ...){
  if (!inherits(x, "SpatRaster")) {
    if (inherits(x, "RasterStack")) {
      x <- rast(x)
    }
    else if (is.list(x)) {
      x <- rast(lapply(x, rast))
    }
    else{
      stop("Invalid x.")
    }
  }
  avgs <- vector(length = nlyr(x))
  for(i in 1:nlyr(x)){
    avg <- mean(as.matrix(x[[i]]), na.rm = TRUE)
    avgs[i] <- avg
  }
  if(mean.only == FALSE){
    sd1 <- stats::sd(avgs[which(sat.order == to.from[1])], na.rm = TRUE)
    sd2 <- stats::sd(avgs[which(sat.order == to.from[2])], na.rm = TRUE)
    x[[which(sat.order == to.from[2])]] <- x[[which(sat.order == to.from[2])]]*sd1/sd2
    avgs <- sapply(1:nlyr(x), function(i) mean(as.matrix(x[[i]]), na.rm = TRUE))
  }
  avg1 <- mean(avgs[which(sat.order == to.from[1])], na.rm = TRUE)
  avg2 <- mean(avgs[which(sat.order == to.from[2])], na.rm = TRUE)
  avg.diff <- avg1 - avg2
  x[[which(sat.order == to.from[2])]] <- x[[which(sat.order == to.from[2])]] + avg.diff
  return(x)
  if (filename != "") {
    writeRaster(x, filename, ...)
  }
}
