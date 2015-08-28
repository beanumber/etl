#' @rdname etl_create
#' @export

etl_extract <- function(obj, ...) UseMethod("etl_extract")

#' @rdname etl_create
#' @method etl_extract default
#' @export

etl_extract.default <- function(obj, ...) {
  # download the data from the Internet
  warning(paste0("No available methods. Did you write the method etl_extract.", class(obj)[1]), "()?")
  return(obj)
}

#' @rdname etl_create
#' @method etl_extract etl_mtcars
#' @export

etl_extract.etl_mtcars <- function(obj, ...) {
  if (!dir.exists(obj$dir)) {
    obj$dir <- tempdir()
  }
  filename <- paste0(obj$dir, "/mtcars.csv")
  write.csv(mtcars, file = filename)
  return(obj)
}


