#' @title Update an existing DB
#'
#' @inheritParams etl_init
#' @export
#' @family etl functions
#' @examples
#'
#' \dontrun{
#' require(RPostgreSQL)
#' require(dplyr)
#' db <- src_postgres("mtcars", user = "postgres", host = "localhost")
#' etl_cars <- etl_connect("mtcars", db)
#' etl_cars %>%
#'  etl_init() %>%
#'  etl_update() %>%
#'  str()
#' }

etl_update <- function(obj, ...) UseMethod("etl_update")

#' @rdname etl_update
#' @method etl_update default
#' @export

etl_update.default <- function(obj, ...) {
  obj <- obj %>%
    etl_extract(...) %>%
    etl_process(...) %>%
    etl_push(...)
  if (!is.null(obj$push)) {
    etl_cleanup(obj, ...)
  } else {
    warning("Unable to push data to the database?")
  }
  return(obj)
}
