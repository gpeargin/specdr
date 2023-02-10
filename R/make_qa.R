#' Create a QA Layer for Harmonized Landsat Sentinel-2 Data
#'
#' Creates a QA layer for a Harmonized Landsat Sentinel-2 (HLSL/HLSS) image. Masks clouds, snow, etc. while ranking the unmasked pixels according to aerosol level.
#'
#' @param x A HLS Fmask layer. Either a SpatRaster, RasterLayer, or file path.
#' @param keep Character vector of pixel classifications to be excluded from masking. Options are "Water," "Snow/ice," "Cloud shadow," "Adjacent to cloud/shadow," and "Cloud".
#' @param filename Output file path.
#' @param ... Additional arguments to pass to `writeRaster`.
#'
#' @return A SpatRaster. Non-NA pixel values are 0 (Low aerosol), 1 (Moderate aerosol), or 2 (High aerosol).
#' @source The Fmask lookup table used in this function can be obtained by downloading HLS data through \href{https://appeears.earthdatacloud.nasa.gov/}{AppEEARS}.
#' @importFrom raster raster
#' @export
#'
#' @examples
#' data(fm_ex)
#' plot(fm_ex)
#'
#' #QA layer with all categories masked
#' qa <- make.qa(fm_ex)
#' plot(qa)
#'
#' #QA layer with cloud shadow and adjacent pixels retained
#' qa <- make.qa(fm_ex, keep = c("Cloud shadow", "Adjacent to cloud/shadow"))
#' plot(qa)

make.qa <- function(x,
                    keep = NULL,
                    filename = "",
                    ...) {
  if (is.character(x) | inherits(x, "RasterLayer")) {
    x <- rast(x)
  }
  lut <- as.data.frame(fmask_lut)
  lut$class <- rep(NA, nrow(lut))
  for (val in lut$Value) {
    if (all(lut[which(lut$Value == val), c(3:7)[which(!(names(fmask_lut) %in% keep)[3:7] == TRUE)]] == "No")) {
      if (lut[which(lut$Value == val), 2] == "Low aerosol") {
        lut$class[which(lut$Value == val)] <- 0
      }
      else if (lut[which(lut$Value == val), 2] == "Moderate aerosol") {
        lut$class[which(lut$Value == val)] <- 1
      }
      else{
        lut$class[which(lut$Value == val)] <- 2
      }
    }
  }
  qa <-
    classify(x, matrix(c(lut$Value, lut$class), ncol = 2))
  if (filename != "") {
    writeRaster(qa, filename, ...)
  }
  return(qa)
}
