#' @rdname etl_create
#' @export

etl_transform <- function(obj, ...) UseMethod("etl_transform")

#' @rdname etl_create
#' @method etl_transform default
#' @export

etl_transform.default <- function(obj, ...) {
  # load the data and process it if necessary
  message(paste0("No available methods. Did you write the method etl_transform.", class(obj)[1]), "()?")
  invisible(obj)
}

#' @rdname etl_create
#' @method etl_transform etl_mtcars
#' @export

etl_transform.etl_mtcars <- function(obj, ...) {
  message("Transforming raw data...")
  raw_dir <- paste0(attr(obj, "dir"), "/raw")
  if (!dir.exists(raw_dir)) {
    stop("The directory with the raw data does not exist. Please specify a valid path to the raw data.")
  }
  # load the data and process it if necessary
  invisible(obj)
}


