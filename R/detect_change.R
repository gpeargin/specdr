#' Detect Changes in a Raster Time Series
#'
#' Applies a change detection algorithm to all pixels in a raster time series.
#'
#' @param x Raster time series. Either a SpatRaster, a RasterStack, or a list of SpatRasters, RasterLayers, or file paths.
#' @param t.Gregorian Vector of dates associated with the time series. Use %Y-%m-%d format.
#' @param t.fit Time window used to fit new models, expressed in number of (whole) days.
#' @param min.obs.fit Minimum number of observations to fit an initial model. If fewer than `min.obs.fit` observations in the initial fitting period are not `NA`, the pixel will be skipped. Does not apply to subsequent models.
#' @param filename Output file path. Valid extensions are .rdata, .rds, .json, and .yaml.
#' @param ... Additional arguments to pass to `detect.change.harmonic`.
#'
#' @return A list containing two sublists. `$info` contains the raster's dimensions, coordinate reference system, extent, and resolution, while `$changes` pairs the output of `detect.change.harmonic` with the index of the corresponding pixel. Only pixels for which a change occurred are included in `$changes`, and if no changes occurred or all pixels were skipped, `$changes` will simply be `NA`.
#' @import terra
#' @importFrom raster stack
#' @importFrom rlist list.save
#' @importFrom rlist list.stack
#' @export
#'
#' @examples
#' #load/create data
#' data(arr_ex)
#' data(ts_ex)
#'
#' #detect changes
#' cl_ex <- detect.change(rast(arr_ex), tg_ex, flag.stat = "iqr")
#' print("info")
#' cl_ex$info
#' print("changes")
#' cl_ex$changes[[1]]
#' print(paste0("length: ", length(cl_ex$changes)))
detect.change <-
  function(x,
           t.Gregorian,
           t.fit = 365,
           min.obs.fit = 1,
           filename = "",
           ...) {
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
    index <-
      which(values(app(not.na(x)[[1:length(which(t.Gregorian <= t.Gregorian[1] + lubridate::days(t.fit)))]], sum)) >= min.obs.fit)
    if (length(index) > 0) {
      changes <- vector("list", length = length(index))
      empty <- vector()

      pb <-
        progress::progress_bar$new(
          format = "(:spin) [:bar] :percent [Elapsed time: :elapsedfull || Estimated time remaining: :eta]",
          total = length(changes),
          complete = "=",
          incomplete = "-",
          current = ">",
          clear = FALSE,
          width = 100,
          show_after = 0
        )

      for (i in 1:length(changes)) {
        pb$tick()
        rc <- rowColFromCell(x[[1]], index[i])
        changes[[i]] <-
          detect.change.harmonic(as.array(x)[rc[1], rc[2],],
                                 t.Gregorian,
                                 ...)
        changes[[i]]$position <- index[i]
        if (length(changes[[i]]$change.index) == 0) {
          empty[length(empty) + 1] <- i
        }
      }
      if (length(empty) > 0) {
        changes <- changes[[-empty]]
        if (length(changes) == 0) {
          changes <- list(NA)
        }
      }
      list_out <- list(
        info = list(
          dim = c(nrow(x), ncol(x)),
          crs = as.character(crs(x, proj = TRUE)),
          ext = ext(x)[1:4],
          res = res(x)
        ),
        changes = changes
      )
    }
    else{
      list_out <- list(info = list(
        dim = c(nrow(x), ncol(x)),
        crs = as.character(crs(x, proj = TRUE)),
        ext = ext(x)[1:4],
        res = res(x)
      ), NA)
    }
    if (list_out$info$crs == "") {
      list_out$info$crs <- NA
    }
    if (filename != "") {
      rlist::list.save(list_out, filename)
    }
    return(list_out)
  }
