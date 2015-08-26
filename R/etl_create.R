#' @title Create and populate a database from an online source
#'
#' @inheritParams etl_init
#' @export
#' @return the result of \code{\link{etl_update}}
#' @family etl functions
#' @examples
#'
#' \dontrun{
#' require(RPostgreSQL)
#' require(dplyr)
#' db <- src_postgres("mtcars", user = "postgres", host = "localhost")
#' etl_cars <- etl_connect("mtcars", db)
#' str(etl_create(etl_cars))
#' }

etl_create <- function(obj, ...) UseMethod("etl_create")

#' @rdname etl_create
#' @method etl_create default
#' @export

etl_create.default <- function(obj, ...) {
  if (is.null(obj$init)) {
    obj <- etl_init(obj, ...)
  }
  etl_update(obj, ...)
}
