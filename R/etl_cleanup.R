#' @rdname etl_create
#' @export

etl_cleanup <- function(obj, ...) UseMethod("etl_cleanup")

#' @rdname etl_create
#' @method etl_cleanup default
#' @export

etl_cleanup.default <- function(obj, ...) {
  # delete files
  # run VACCUUM ANALYZE, etc.
  message(paste0("No available methods. Did you write the method etl_cleanup.", class(obj)[1]), "()?")
  return(obj)
}

#' @rdname etl_create
#' @method etl_cleanup etl_mtcars
#' @export

etl_cleanup.etl_mtcars <- function(obj, ...) {
  # delete files
  # run VACCUUM ANALYZE, etc.
  return(obj)
}
