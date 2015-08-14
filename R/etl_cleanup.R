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
#' db <- etl_connect("mtcars", user = "postgres", password = "scem8467", host = "localhost", port = 5433)
#' etl_init(db)
#' etl_push(db)
#' etl_cleanup(db)
#'

etl_cleanup <- function (con, dir, ...) UseMethod("etl_cleanup")

#' @rdname etl_cleanup
#' @method etl_cleanup default
#' @export

etl_cleanup.default <- function (con, dir, ...) {
  # delete files
  # run VACCUUM ANALYZE, etc.
}
