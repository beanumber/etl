#' @title Update an existing DB
#'
#' @inheritParams etl_init
#' @export
#' @family etl functions
#' @examples
#'
#' require(RPostgreSQL)
#' # connect directly
#' db <- etl_connect("mtcars", user = "postgres", password = "scem8467", host = "localhost", port = 5433)
#' etl_update(db)
#'

etl_update <- function (con, ...) UseMethod("etl_update")

#' @rdname etl_update
#' @method etl_update default
#' @export

etl_update.default <- function (con, ...) {
  dir <- etl_scrape(con, ...)
  dir <- etl_process(dir, ...)
  if (etl_push(con, dir, ...)) {
    etl_cleanup(con, dir, ...)
  }
}
