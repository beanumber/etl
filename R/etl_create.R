#' @title Create and populate a database from an online source
#'
#' @inheritParams etl_init
#' @export
#' @return the result of \code{\link{etl_update}}
#' @family etl functions
#' @examples
#'
#' require(RPostgreSQL)
#' # connect directly
#' db <- etl_connect("mtcars", user = "postgres", password = "scem8467", host = "localhost", port = 5433)
#' etl_create(db)
#'

etl_create <- function (con, ...) UseMethod("etl_create")

#' @rdname etl_create
#' @method etl_create default
#' @export

etl_create.default <- function (con, ...) {
  if (etl_init(con, ...)) {
    etl_update(con, ...)
  }
}
