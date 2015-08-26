#' @title Cleanup after data loaded into DB
#'
#' @inheritParams etl_init
#' @return NULL
#' @export
#' @family etl functions
#' @examples
#'
#' require(RPostgreSQL)
#' # connect directly
#' require(dplyr)
#' db <- src_postgres("mtcars", user = "postgres", password = "postgres", host = "localhost")
#' etl_cars <- etl_connect("mtcars", db)
#' etl_cars %>%
#'  etl_create() %>%
#'  etl_cleanup()
#'

etl_cleanup <- function(obj, ...) UseMethod("etl_cleanup")

#' @rdname etl_cleanup
#' @method etl_cleanup default
#' @export

etl_cleanup.default <- function(obj, ...) {
  # delete files
  # run VACCUUM ANALYZE, etc.
}
