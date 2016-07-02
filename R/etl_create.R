#' @title ETL functions for working with medium sized data
#' @description These generic functions provide a systematic approach
#' for performing ETL (exchange-transform-load) operations on medium
#' sized data.
#'
#' @param obj an \code{\link{etl}} object
#' @param ... arguments passed to methods
#' @export
#' @details The purposes of these functions are to download data from a
#' particular data source from the Internet, process it, and load it
#' into a SQL database server.
#'
#' There are five primary functions:
#' \describe{
#'  \item{\code{\link{etl_init}}}{Initialize the database schema.}
#'  \item{etl_extract}{Download data from the Internet and store it locally in
#'  its raw form.}
#'  \item{etl_transform}{Manipulate the raw data such that it can be loaded
#'  into a database table. Usually, this means converting the raw data to
#'  (a series of) CSV files, which are also stored locally.}
#'  \item{etl_load}{Load the transformed data into the database.}
#'  \item{etl_cleanup}{Perform housekeeping, such as deleting unnecessary
#'  raw data files.}
#' }
#'
#' Additionally, two convenience functions chain these operations together:
#' \describe{
#'  \item{etl_create}{Run all five functions in succession.
#'  This is useful when you want
#'  to create the database from scratch.}
#'  \item{etl_update}{Run the \code{etl_extract}-\code{etl_transform}-\code{etl_load} functions
#'  in succession.
#'  This is useful
#'  when the database already exists, but you want to insert some new data. }
#' }
#' @return Each one of these functions returns an \code{\link{etl}} object, invisibly.
#' @seealso \code{\link{etl}}, \code{\link{etl_init}}
#' @examples
#'
#' \dontrun{
#' if (require(RPostgreSQL)) {
#'   db <- src_postgres(dbname = "mtcars", user = "postgres", host = "localhost")
#'   cars <- etl("mtcars", db)
#' }
#' if (require(RMySQL)) {
#'   db <- src_mysql(dbname = "mtcars", user = "r-user", host = "localhost", password = "mypass")
#'   cars <- etl("mtcars", db)
#' }
#' }
#' cars <- etl("mtcars")
#' cars %>%
#'  etl_extract() %>%
#'  etl_transform() %>%
#'  etl_load() %>%
#'  etl_cleanup()
#' cars
#'
#' cars %>%
#'  tbl(from = "mtcars") %>%
#'  group_by(cyl) %>%
#'  summarise(N = n(), mean_mpg = mean(mpg))
#'
#'  # do it all in one step, and peek at the SQL creation script
#'  cars %>%
#'    etl_create(echo = TRUE)
#'  # specify a directory for the data
#'  \dontrun{
#'  cars <- etl("mtcars", dir = "~/dumps/mtcars/")
#'  str(cars)
#'  }

etl_create <- function(obj, ...) UseMethod("etl_create")

#' @rdname etl_create
#' @method etl_create default
#' @export

etl_create.default <- function(obj, ...) {
  obj <- obj %>%
    etl_init(...) %>%
    etl_update(...) %>%
    etl_cleanup(...)
  invisible(obj)
}

#' @rdname etl_create
#' @export

etl_update <- function(obj, ...) UseMethod("etl_update")

#' @rdname etl_create
#' @method etl_update default
#' @export

etl_update.default <- function(obj, ...) {
  obj <- obj %>%
    etl_extract(...) %>%
    etl_transform(...) %>%
    etl_load(...)
  invisible(obj)
}
