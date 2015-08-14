#' @title Initialize the DB with schema
#'
#' @param con a \code{\link[DBI]{DBIConnection-class}} object
#' @param ... arguments passed to methods
#' @return the result from \code{\link{dbRunScript}}
#' @family etl functions
#' @export
#' @examples
#'
#' require(RPostgreSQL)
#' # connect directly
#' db <- etl_connect("mtcars", user = "postgres", password = "scem8467", host = "localhost", port = 5433)
#' etl_init(db)

etl_init <- function (con, ...) UseMethod("etl_init")

#' @rdname etl_init
#' @method etl_init default
#' @export

etl_init.default <- function (con, ...) {
#  sql <- system.file("inst", package = "etl")
  dbRunScript(con, "~/Dropbox/lib/etl/inst/sql/mtcars.psql")
}


