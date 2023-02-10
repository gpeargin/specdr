#' Remove Extreme Values from a Raster
#'
#' @param raster A SpatRaster, RasterLayer, or file path.
#' @param filename Output file path.
#' @param ... Additional argument to pass to `writeRaster`.
#'
#' @return A SpatRaster.
#' @export
#'
#' @examples
#' set.seed(1)
#' m <- matrix(rbinom(100, 10, 0.5), nrow = 10)
#' s <- sample(1:100, 5)
#' m[s] <- 100
#'
#' r <- rast(m)
#' plot(r)
#'
#' r <- remove.outliers(r)
#' plot(r)
remove.outliers <- function(raster, filename = "", ...) {
  if(is.character(raster) | inherits(raster, "RasterLayer")){
    raster <- rast(raster)
  }
  iqr <- stats::IQR(values(raster), na.rm = TRUE)
  q1 <- stats::quantile(values(raster), 0.25, na.rm = TRUE)
  q3 <- stats::quantile(values(raster), 0.75, na.rm = TRUE)
  out <-
    which(values(raster) < q1 - 1.5 * iqr |
            values(raster) > q3 + 1.5 * iqr)
  if (length(out) > 0) {
    values(raster)[out] <- NA
  }
  if (filename != "") {
    writeRaster(raster, filename, ...)
  }
  return(raster)
}
