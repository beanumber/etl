#' etl-class
#' @format
#' \describe{
#'  \item{pkg}{the name of the package corresponding to the data source}
#'  \item{con}{an objection of class \code{\link[DBI]{DBIConnection-class}}}
#'  \item{dir}{the directory where the raw data is stored}
#'  \item{init}{has the database been initialized?}
#'  \item{push}{a vector a messages from \code{\link[DBI]{dbWriteTable}}}
#'  \item{files}{a list of files that have been downloaded}
#'  }
#' @export
etl <- function()

#' etl_mtcars-class
#'
#' @export
NULL





# S4 class definition
# setClass("etl_mtcars", contains = "DBIConnection")
#
# setIs("etl_mtcars", "PostgreSQLConnection",
#       coerce = function(from) from,
#       replace= function(from, value) {
#         from <- value; from })

