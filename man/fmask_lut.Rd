% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{fmask_lut}
\alias{fmask_lut}
\title{Fmask Lookup Table}
\format{
A data.frame with 42 rows and 8 columns:
\itemize{
\item{names:}{"Value," "Aerosol level," "Water," "Snow/ice," "Cloud shadow," "Cloud," "Cirrus / Reserved, but not used"}
}
}
\source{
AppEEARS Team. (2022). Application for Extracting and Exploring Analysis Ready Samples (AppEEARS). Ver. 3.19. NASA EOSDIS Land Processes Distributed Active Archive Center (LP DAAC), USGS/Earth Resources Observation and Science (EROS) Center, Sioux Falls, South Dakota, USA. Accessed December 9, 2022. \href{https://appeears.earthdatacloud.nasa.gov}{https://appeears.earthdatacloud.nasa.gov}.

Masek, J., Ju, J., Roger, J., Skakun, S., Vermote, E., Claverie, M., Dungan, J., Yin, Z., Freitag, B., Justice, C. (2021). HLS Operational Land Imager Surface Reflectance and TOA Brightness Daily Global 30m v2.0. NASA EOSDIS Land Processes DAAC. Accessed 2022-12-09 from \href{https://doi.org/10.5067/HLS/HLSL30.002}{https://doi.org/10.5067/HLS/HLSL30.002}. Accessed December 9, 2022.
}
\usage{
fmask_lut
}
\description{
Matches bit-packed Harmonized Landsat Sentinel-2 (HLS) Fmask values with pixel classifications and aerosol levels.
}
\keyword{datasets}
