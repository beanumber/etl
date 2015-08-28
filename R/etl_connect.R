#' @title Connect to a SQL database
#'
#' @param x the name of the package that you wish to populate
#' @param db_con a \code{\link[dplyr]{src}} or
#' \code{\link[DBI]{DBIConnection-class}} object
#' @param dir a directory to store the raw data files
#' @param ... arguments passed to methods
#' @return an object of class \code{etl_*} and \code{\link{etl}}
#' @export
#' @family etl functions
#' @examples
#'
#' \dontrun{
#' require(RPostgreSQL)
#' # connect using dplyr
#' require(dplyr)
#' db <- src_postgres("mtcars", user = "postgres",
#' host = "localhost")
#' etl_cars <- etl_connect("mtcars", db)
#' str(etl_cars)
#'
#' # connect using DBI
#' con <- dbConnect(RPostgreSQL::PostgreSQL(), user = "postgres",
#' host = "localhost", dbname = "mtcars")
#' etl_cars <- etl_connect("mtcars", db)
#' }

etl_connect <- function(x, db_con, dir = tempdir(), ...) UseMethod("etl_connect")

#' @rdname etl_connect
#' @method etl_connect default
#' @export

etl_connect.default <- function(x, db_con, dir = tempdir(), ...) {
  if (x != "mtcars") {
    message(paste0("Please make sure that the '", x, "' package is loaded"))
  }
  if (is(db_con, "src")) {
    conn <- db_con$con
  } else {
    conn <- db_con
  }
  if (!is(conn, "DBIConnection")) {
    stop("Could not make connection to database.")
  }
  obj <- list("pkg" = x, con = conn, dir = normalizePath(dir), init = NULL,
              files = NULL, push = NULL)
  class(obj) <- c(paste0("etl_", x), "etl")
  return(obj)
}

