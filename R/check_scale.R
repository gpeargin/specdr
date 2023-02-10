#' Check and Correct Raster Scale
#'
#' Compare the difference in significant digits between the average value of a raster and a scalar. If the difference in significant digits exceeds a threshold, the raster is multiplied by the scalar.
#'
#' @param raster A SpatRaster, RasterLayer, or file path.
#' @param scalar Target scale. If the average value of the raster differs from this number too greatly, the raster will be multiplied by this number.
#' @param tolerance Tolerated difference in significant figures between scalar and average raster value. Exceeding this value results in rescaling.
#' @param filename Output file path.
#' @param ... Additional argument to pass to `writeRaster`.
#'
#' @return A SpatRaster.
#' @export
#'
#' @examples
#' set.seed(1)
#' m <- matrix(rnorm(100), nrow = 10)
#' r <- rast(m)
#' mean(values(r))
#'
#' #check r for proper scale, rescale if needed
#' r <- check.scale(r, 10000, 1)
#' mean(values(r))
check.scale <-
  function(raster,
           scalar,
           tolerance = 1,
           filename = "",
           ...) {
    if (is.character(raster) | inherits(raster, "RasterLayer")) {
      raster <- rast(raster)
    }
    avg <- mean(values(raster), na.rm = TRUE)
    if (!is.na(avg)) {
      e.scalar <- as.integer(strsplit(format(scalar, scientific = TRUE), "e")[[1]][2])
      e.avg <- as.integer(strsplit(format(avg, scientific = TRUE), "e")[[1]][2])
      if (abs(e.scalar - e.avg) > tolerance) {
        raster <- raster * scalar
      }
    }
    if (filename != "") {
      writeRaster(raster, filename, ...)
    }
    return(raster)
  }
