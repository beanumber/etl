#' @title Process raw data into a format suitable for DB insert
#'
#' @inheritParams etl_init
#' @export
#' @return the \code{\link{etl}} object
#' @seealso etl_init
#' @family etl functions
#' @examples
#'
#' \dontrun{
#' require(RPostgreSQL)
#' require(dplyr)
#' db <- src_postgres("mtcars", user = "postgres", password = "postgres", host = "localhost")
#' etl_cars <- etl_connect("mtcars", db)
#' etl_cars %>%
#'  etl_scrape() %>%
#'  etl_process() %>%
#'  str()
#' }

etl_process <- function(obj, ...) UseMethod("etl_process")

#' @rdname etl_process
#' @method etl_process default
#' @export

etl_process.default <- function(obj, ...) {
  # load the data and process it if necessary
  message(paste0("No available methods. Did you write the method etl_process.", class(obj)[1]), "()?")
  return(obj)
}

#' @rdname etl_process
#' @method etl_process etl_mtcars
#' @export

etl_process.etl_mtcars <- function(obj, ...) {
  if (!dir.exists(obj$dir)) {
    stop("Directory does not exist! Please specify a valid path to the raw data.")
  }
  # load the data and process it if necessary
  return(obj)
}


