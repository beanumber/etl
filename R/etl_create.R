#' @title ETL functions for working with medium sized data
#' @description These generic functions provide a systematic approach
#' for performing ETL (exchange-transform-load) operations on medium
#' sized data.
#'
#' @param obj an \code{\link{etl}} object
#' @param ... arguments passed to methods
#' @export
#' @details The purpose of these functions are to download data from a
#' particular data source from the Internet, process it, and load it
#' into a SQL database server.
#'
#' There are five primary functions:
#' \describe{
#'  \item{etl_init}{Initialize the database. For RDBMSs, an SQL initialization
#'  script is sent to the DB.}
#'  \item{etl_extract}{Download data from the Internet and store it locally in
#'  its raw form.}
#'  \item{etl_transform}{Maniuplate the raw data such that it can be loaded
#'  into a database table. Usually, this means converting the raw data to
#'  (a series of) CSV files, which are also stored locally.}
#'  \item{etl_load}{Load the transformed data into the database.}
#'  \item{etl_cleanup}{Perform housekeeping, such as deleting unnecessary
#'  raw data files.}
#' }
#'
#' Additionally, two convenience function chain these operations together:
#' \describe{
#'  \item{etl_create}{Run all five in succession. This is useful when you want
#'  to create the database from scratch.}
#'  \item{etl_update}{Run all four, excepting \code{etl_init}. This is useful
#'  where the database already exists, but you want to insert some new data. }
#' }
#' @return Each one of these functions returns an \code{\link{etl}} object.
#' @seealso \code{\link{etl}}
#' @examples
#'
#' require(magrittr)
#' if (require(RSQLite) & require(dplyr)) {
#'  db <- src_sqlite(path = tempfile(), create = TRUE)
#'  cars <- etl("mtcars", db)
#'  cars %>%
#'    etl_init() %>%
#'    etl_extract() %>%
#'    etl_transform() %>%
#'    etl_load() %>%
#'    etl_cleanup()
#'  db %>%
#'    tbl(from = "mtcars") %>%
#'    group_by(cyl) %>%
#'    summarise(N = n(), meanMPG = mean(mpg))
#' }

etl_create <- function(obj, ...) UseMethod("etl_create")

#' @rdname etl_create
#' @method etl_create default
#' @export

etl_create.default <- function(obj, ...) {
  if (is.null(obj$init)) {
    obj <- etl_init(obj, ...)
  }
  etl_update(obj, ...)
}
