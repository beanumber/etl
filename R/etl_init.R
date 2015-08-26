#' @title Initialize the DB with schema
#'
#' @param obj an \code{\link{etl}} object
#' @param ... arguments passed to methods
#' @return the \code{\link{etl}} object
#' @family etl functions
#' @export
#' @examples
#'
#' require(RPostgreSQL)
#' require(dplyr)
#' db <- src_postgres("mtcars", user = "postgres", password = "postgres", host = "localhost")
#' etl_cars <- etl_connect("mtcars", db)
#' str(etl_cars)

etl_init <- function(obj, ...) UseMethod("etl_init")

#' @rdname etl_init
#' @method etl_init default
#' @export

etl_init.default <- function(obj, ...) {
#  sql <- system.file("inst", package = "etl")
  obj$init <- dbRunScript(obj$con, "~/Dropbox/lib/etl/inst/sql/mtcars.psql")
  return(obj)
}


