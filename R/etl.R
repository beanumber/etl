#' Initialize an etl object
#'
#' @description Initialize en etl object
#'
#' @param x the name of the package that you wish to populate.
#' This determines the class of the \code{\link{etl}} object, which
#' determines method dispatch of \code{etl_*()} functions.
#' @param db a database connection that inherits from \code{\link[dplyr]{src_sql}}. It is
#' NULL by default, which results in a \code{\link[dplyr]{src_sqlite}} connection being made
#' @param dir a directory to store the raw data files
#' @param ... arguments passed to methods
#' @details An \code{\link{etl}} object extends a \code{\link[dplyr]{src_sql}} object.
#' It also has attributes for:
#' \describe{
#'  \item{pkg}{the name of the package corresponding to the data source}
#'  \item{dir}{the directory where the raw data is stored}
#'  \item{push}{a vector a messages from \code{\link[DBI]{dbWriteTable}}}
#'  \item{files}{a list of files that have been downloaded}
#'  }
#' @return an object of class \code{etl_x} and \code{\link{etl}} that inherits
#' from \code{\link[dplyr]{src_sql}}
#' @export
#' @seealso \code{\link{etl_create}}
#' @examples
#'
#' # Instantiate the etl object
#' cars <- etl("mtcars")
#' str(cars)
#' is.etl(cars)
#'
#' \dontrun{
#' # connect using dplyr
#' if (require(RPostgreSQL)) {
#'  db <- src_postgres("mtcars", user = "postgres", host = "localhost")
#'  cars <- etl("mtcars", db)
#' }
#' }
#'
#' # Do it step-by-step
#' cars %>%
#'   etl_extract() %>%
#'   etl_transform() %>%
#'   etl_load()
#' src_tbls(cars)
#' cars %>%
#'   tbl("mtcars") %>%
#'   group_by(cyl) %>%
#'   summarize(N = n(), mean_mpg = mean(mpg))
#'
#' # Do it all in one step
#' cars2 <- etl("mtcars")
#' cars2 %>%
#'   etl_update()
#' src_tbls(cars2)
#'


etl <- function(x, db = NULL, dir = tempdir(), ...) UseMethod("etl")

#' @rdname etl
#' @method etl default
#' @export

etl.default <- function(x, db = NULL, dir = tempdir(), ...) {
  if (x != "mtcars") {
    if (!requireNamespace(x)) {
      stop(paste0("Please make sure that the '", x, "' package is installed"))
    }
  }
  db <- verify_con(db)
  obj <- structure(db, data = NULL, "pkg" = x, dir = normalizePath(dir),
              files = NULL, push = NULL, class = c(paste0("etl_", x), "etl", class(db)))
  return(obj)
}


# S4 class definition
# setClass("etl_mtcars", contains = "DBIConnection")
#
# setIs("etl_mtcars", "PostgreSQLConnection",
#       coerce = function(from) from,
#       replace= function(from, value) {
#         from <- value; from })



