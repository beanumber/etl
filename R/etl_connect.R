#' @title Connect to a SQL database
#'
#' @param x the name of the package that you wish to populate
#' @param db_con a \code{\link[dplyr]{src}} or
#' \code{\link[DBI]{DBIConnection-class}} object
#' @param ... arguments passed to methods
#' @export
#' @family etl functions
#' @examples
#'
#' require(RPostgreSQL)
#'
#' # connect using dplyr
#' require(dplyr)
#' db <- src_postgres("airlines", user = "postgres", password = "scem8467", host = "localhost", port = 5433)
#' etl_cars <- etl_connect("mtcars", db)
#' class(etl_cars)
#' etl_cars
#'
#' # connect using DBI
#' con <- dbConnect(RPostgreSQL::PostgreSQL(), user = "postgres", password = "scem8467", host = "localhost", dbname = "airlines", port = 5433)
#' etl_cars <- etl_connect("mtcars", db)
#'

etl_connect <- function (x, db_con, ...) UseMethod("etl_connect")

#' @rdname etl_connect
#' @method etl_connect default
#' @export

etl_connect.default <- function (x, db_con, ...) {
  if (x != "mtcars") {
    message(paste("Please make sure that the package", x, "is loaded"))
  }
  if (is(db_con, "src")) {
    conn <- db$con
  } else {
    conn <- con
  }
  if (!is(conn, "DBIConnection")) {
    stop("Could not make connection to database.")
  }
  # class(conn) <- c(paste0("etl_", x), class(conn))
  as(conn, "etl_mtcars", strict = FALSE)
  return(conn)
}

#' @rdname etl_connect
#' @method etl_connect mtcars
#' @export
