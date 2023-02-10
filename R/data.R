#' Example 3-Dimensional Array
#'
#' Example array constructed from `ts_ex`. Is converted to SpatRaster and used as input to `detect.changes`.
#'
#' @format An array with dim = c(5,5,300).
"arr_ex"

#' Example Change List
#'
#' Output of `detect.changes`; used as input for `measure.change`.
#'
#' @format List of lists. `$info` contains raster properties, while `$changes` details changes detected by `detect.changes`.
"cl_ex"

#' Fmask Lookup Table
#'
#' Matches bit-packed Harmonized Landsat Sentinel-2 (HLS) Fmask values with pixel classifications and aerosol levels.
#'
#' @format
#' A data.frame with 42 rows and 8 columns:
#' \itemize{
#' \item{names:}{"Value," "Aerosol level," "Water," "Snow/ice," "Cloud shadow," "Cloud," "Cirrus / Reserved, but not used"}
#' }
#' @source AppEEARS Team. (2022). Application for Extracting and Exploring Analysis Ready Samples (AppEEARS). Ver. 3.19. NASA EOSDIS Land Processes Distributed Active Archive Center (LP DAAC), USGS/Earth Resources Observation and Science (EROS) Center, Sioux Falls, South Dakota, USA. Accessed December 9, 2022. \href{https://appeears.earthdatacloud.nasa.gov}{https://appeears.earthdatacloud.nasa.gov}.
#' @source Masek, J., Ju, J., Roger, J., Skakun, S., Vermote, E., Claverie, M., Dungan, J., Yin, Z., Freitag, B., Justice, C. (2021). HLS Operational Land Imager Surface Reflectance and TOA Brightness Daily Global 30m v2.0. NASA EOSDIS Land Processes DAAC. Accessed 2022-12-09 from \href{https://doi.org/10.5067/HLS/HLSL30.002}{https://doi.org/10.5067/HLS/HLSL30.002}. Accessed December 9, 2022.
"fmask_lut"

#' Example Fmask raster
#'
#' @format
#' A RasterLayer with 3660 rows and 3660 columns.
#' \itemize{
#' \item{satellite:}{Landsat 8/9}
#' \item{date:}{2014.08.25}
#' \item{time:}{18:05:15}
#' \item{crs:}{+proj=utm +zone=12 +ellps=WGS84 +units=m +no_defs}
#' \item{res:}{30}
#' \item{ext:}{443880, 454860, 3923160, 3934140 (xmin, xmax, ymin, ymax)}
#' }
#' @source AppEEARS Team. (2022). Application for Extracting and Exploring Analysis Ready Samples (AppEEARS). Ver. 3.19. NASA EOSDIS Land Processes Distributed Active Archive Center (LP DAAC), USGS/Earth Resources Observation and Science (EROS) Center, Sioux Falls, South Dakota, USA. Accessed December 9, 2022. \href{https://appeears.earthdatacloud.nasa.gov}{https://appeears.earthdatacloud.nasa.gov}.
#' @source Earthdata Search. 2019. Greenbelt, MD: Earth Science Data and Information System (ESDIS) Project, Earth Science Projects Division (ESPD), Flight Projects Directorate, Goddard Space Flight Center (GSFC) National Aeronautics and Space Administration (NASA). URL:  \href{https://search.earthdata.nasa.gov}{https://search.earthdata.nasa.gov}.
#' @source Masek, J., Ju, J., Roger, J., Skakun, S., Vermote, E., Claverie, M., Dungan, J., Yin, Z., Freitag, B., Justice, C. (2021). HLS Operational Land Imager Surface Reflectance and TOA Brightness Daily Global 30m v2.0. NASA EOSDIS Land Processes DAAC. Accessed 2022-12-09 from \href{https://doi.org/10.5067/HLS/HLSL30.002}{https://doi.org/10.5067/HLS/HLSL30.002}. Accessed December 9, 2022.
"fm_ex"

#' Example QA Layer
#'
#' Example QA Layer generated with `make.qa`. Used as input for `mask.clean`.
#'
#' @format A RasterLayer with 10 rows and 10 columns.
"qa_ex"

#'
#' Example Raster Time Series
#'
#' Same as `arr_ex`, but every other raster has a higher mean and variance. Meant to simulate differences in time series from two satellites.
#'
#' @format A RasterLayer with dim = c(5,5,300).
"rts_ex"

#' Example Satellite Order
#'
#' Used by `align.sats` to determine which rasters are from which satellites.
#'
#' @format Character vector of length 300.
"so_ex"

#' Example Gregorian Dates
#'
#' @format Vector of 300 dates spanning Jan 18, 2020 to Apr 28, 2021.
"tg_ex"

#' Example Time Series
#'
#' Represents a time series for a single pixel.
#'
#' @format Numeric vector of length 300.
"ts_ex"
