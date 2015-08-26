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
#' db <- src_postgres("mtcars", user = "postgres", password = "postgres", host = "localhost")
#' etl_cars <- etl_connect("mtcars", db)
#' etl_cars %>%
#'  etl_init() %>%
#'  etl_scrape() %>%
#'  etl_process() %>%
#'  etl_push() %>%
#'  str()
#' }

etl_push <- function(obj, ...) UseMethod("etl_push")

#' @rdname etl_push
#' @method etl_push default
#' @export

etl_push.default <- function(obj, ...) {
  # insert data from somewhere
  warning(paste0("No available methods. Did you write the method etl_push.", class(obj)[1]), "()?")
  return(obj)
}

#' @rdname etl_push
#' @method etl_push etl_mtcars
#' @export

etl_push.etl_mtcars <- function(obj, ...) {
  data <- read.csv(paste0(obj$dir, "/mtcars.csv"))
  obj$push <- dbWriteTable(obj$con, "mtcars", value = data, row.names = FALSE, append = TRUE)
  return(obj)
}
