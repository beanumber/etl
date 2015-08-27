#' @title Initialize the DB with schema
#'
#' @param obj an \code{\link{etl}} object
#' @param ... arguments passed to methods
#' @return the \code{\link{etl}} object
#' @family etl functions
#' @export
#' @examples
#'
#' \dontrun{
#' require(RPostgreSQL)
#' require(dplyr)
#' db <- src_postgres("mtcars", user = "postgres", host = "localhost")
#' etl_cars <- etl_connect("mtcars", db)
#' str(etl_cars)
#' }

etl_init <- function(obj, ...) UseMethod("etl_init")

#' @rdname etl_init
#' @method etl_init default
#' @export

etl_init.default <- function(obj, ...) {
  #  sql <- system.file("inst", package = "etl")
  message(paste0("No available methods. Did you write the method etl_init.", class(obj)[1]), "()?")
  return(obj)
}

#' @rdname etl_init
#' @method etl_init etl_mtcars
#' @export

etl_init.etl_mtcars <- function(obj, ...) {
  if (class(obj$con) == "MySQLConnection") {
    sql <- system.file("sql", "mtcars.mysql", package = "etl")
  } else if (class(obj$con) == "PostgreSQLConnection") {
    sql <- system.file("sql", "mtcars.psql", package = "etl")
  } else {
    sql <- system.file("sql", "mtcars.sql", package = "etl")
  }
  obj$init <- dbRunScript(obj$con, "~/Dropbox/lib/etl/inst/sql/mtcars.psql")
  return(obj)
}


