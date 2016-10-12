#' @rdname etl_create
#' @export

etl_extract <- function(obj, ...) UseMethod("etl_extract")

#' @rdname etl_create
#' @method etl_extract default
#' @export

etl_extract.default <- function(obj, ...) {
  # download the data from the Internet
  warning(paste0("No available methods. Did you write the method etl_extract.", class(obj)[1]), "()?")
  invisible(obj)
}

#' @rdname etl_create
#' @method etl_extract etl_mtcars
#' @importFrom utils write.csv
#' @export

etl_extract.etl_mtcars <- function(obj, ...) {
  message("Extracting raw data...")
  raw_filename <- file.path(attr(obj, "raw_dir"), "mtcars.csv")
  utils::write.csv(datasets::mtcars, file = raw_filename)
  invisible(obj)
}


