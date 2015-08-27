#' Initialize an etl object
#'
#' @param class String specifying the class of the etl object.
#' This class determines method dispatch of \code{etl_*()} functions.
#' @return an \code{\link{etl}} object with a class specified by \code{class}.
#' @export
#' @examples
#'
#' \dontrun{
#' # define, extract, and transform a data source
#' e <- etl("mtcars")
#' e <- etl_extract(e)
#' e <- etl_transform(e)
#' str(e)
#'
#' # create a database and load
#' library(dplyr)
#' db <- src_sqlite(tempfile(fileext = ".sqlite3"), create = TRUE)
#' etl_load(e, db)
#' tbl(db, "mtcars")
#' }
#'

etl <- function(class) {
  if (missing(class)) stop("Must specify a class")
  obj <- list(data = NULL)
  structure(obj, class = c(class, "etl"))
}

#' Extract data and pull into R
#'
#' @param x an \link{etl} object.
#' @param ... arguments passed onto methods
#' @export
etl_extract <- function(x, ...) UseMethod("etl_extract")


#' @rdname etl_extract
#' @method etl_extract mtcars
etl_extract.mtcars <- function(x, ...) {
  data(mtcars, package = "datasets", envir = environment())
  x$data <- mtcars
  x
}

#' Transform data
#'
#' @param x an \link{etl} object.
#' @param ... arguments passed on to methods
#' @export
etl_transform <- function(x, ...) UseMethod("etl_transform")

#' @rdname etl_transform
#' @method etl_transform mtcars
etl_transform.mtcars <- function(x, ...) {
  x$data$makeModel <- row.names(x$data)
  x
}


#' Load data into a database
#'
#' @param x an \link{etl} object.
#' @param conn A database connection (see )
#' @param ... arguments passed on to methods
#' @export
etl_load <- function(x, conn, ...) UseMethod("etl_load")


#' @rdname etl_load
#' @method etl_load mtcars
#' @importFrom DBI dbWriteTable
etl_load.mtcars <- function(x, conn, ...) {
  # ensure conn is a valid database connection
  conn <- if (is(conn, "src")) conn$con else conn
  if (!is(conn, "DBIConnection"))
    stop("Could not make connection to database.")
  res <- DBI::dbWriteTable(conn, name = "mtcars", x$data,
                           overwrite = TRUE, row.names = FALSE)
  invisible(x)
}

#' Update a database
#'
#' @param x an \link{etl} object.
#' @export
etl_update <- function(x, ...) UseMethod("etl_update")

#' Clean a database
#'
#' @param x an \link{etl} object.
#' @export
etl_cleanup <- function(x, ...) UseMethod("etl_cleanup")
