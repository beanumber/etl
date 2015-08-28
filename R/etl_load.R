#' @title Push data to the DB
#'
#' @inheritParams etl_init
#' @export
#' @importFrom DBI dbWriteTable
#' @return the \code{\link{etl}} object
#' @family etl functions
#' @examples
#'
#' \dontrun{
#' require(RPostgreSQL)
#' require(dplyr)
#' db <- src_postgres("mtcars", user = "postgres", host = "localhost")
#' etl_cars <- etl_connect("mtcars", db)
#' etl_cars %>%
#'  etl_init() %>%
#'  etl_extract() %>%
#'  etl_transform() %>%
#'  etl_load()
#' }

etl_load <- function(obj, ...) UseMethod("etl_load")

#' @rdname etl_load
#' @method etl_load default
#' @export

etl_load.default <- function(obj, ...) {
  # insert data from somewhere
  warning(paste0("No available methods. Did you write the method etl_load.", class(obj)[1]), "()?")
  return(obj)
}

#' @rdname etl_load
#' @method etl_load etl_mtcars
#' @export

etl_load.etl_mtcars <- function(obj, ...) {
  data <- read.csv(paste0(obj$dir, "/mtcars.csv"))
  obj$push <- dbWriteTable(obj$con, "mtcars", value = data, row.names = FALSE, append = TRUE)
  return(obj)
}
