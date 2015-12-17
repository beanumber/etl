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
#' @export

etl_extract.etl_mtcars <- function(obj, ...) {
  message("Extracting raw data...")
  raw_dir <- paste0(attr(obj, "dir"), "/raw")
  if (!dir.exists(raw_dir)) {
    dir.create(raw_dir)
  }
  raw_filename <- paste0(raw_dir, "/mtcars.csv")
  write.csv(mtcars, file = raw_filename)
  invisible(obj)
}


