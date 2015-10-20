#' @title Initialize an etl object
#'
#' @param x the name of the package that you wish to populate.
#' This determines the class of the \code{\link{etl}} object, which
#' determines method dispatch of \code{etl_*()} functions.
#' @param db_con a \code{\link[dplyr]{src}} or
#' \code{\link[DBI]{DBIConnection-class}} object
#' @param dir a directory to store the raw data files
#' @param ... arguments passed to methods
#' @details An \code{\link{etl}} object is a list with the following
#' items:
#' \describe{
#'  \item{pkg}{the name of the package corresponding to the data source}
#'  \item{con}{an objection of class \code{\link[DBI]{DBIConnection-class}}}
#'  \item{dir}{the directory where the raw data is stored}
#'  \item{init}{has the database been initialized?}
#'  \item{push}{a vector a messages from \code{\link[DBI]{dbWriteTable}}}
#'  \item{files}{a list of files that have been downloaded}
#'  }
#' @return an object of class \code{etl_x} and \code{\link{etl}}
#' @export
#' @seealso \code{\link{etl_create}}
#' @examples
#'
#' \dontrun{
#'
#' # connect using dplyr
#' if (require(RPostgreSQL) & require(dplyr)) {
#'   db <- src_postgres("mtcars", user = "postgres",
#'   host = "localhost")
#'   cars <- etl("mtcars", db)
#'   str(cars)
#' }
#' # connect using DBI
#' require(DBI)
#' con <- dbConnect(RPostgreSQL::PostgreSQL(), user = "postgres",
#' host = "localhost", dbname = "mtcars")
#' cars <- etl("mtcars", db)
#' str(cars)
#' }

etl <- function(x, db_con, dir = tempdir(), ...) UseMethod("etl")

#' @rdname etl
#' @method etl default
#' @export

etl.default <- function(x, db_con, dir = tempdir(), ...) {
  if (x != "mtcars") {
    if (!requireNamespace(x)) {
      stop(paste0("Please make sure that the '", x, "' package is installed"))
    }
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


# S4 class definition
# setClass("etl_mtcars", contains = "DBIConnection")
#
# setIs("etl_mtcars", "PostgreSQLConnection",
#       coerce = function(from) from,
#       replace= function(from, value) {
#         from <- value; from })



