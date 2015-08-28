#' @title Scrape data from an online source
#'
#' @inheritParams etl_init
#' @export
#' @return the (possibly modified) \code{\link{etl}} object
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
#'  str()
#' }

etl_extract <- function(obj, ...) UseMethod("etl_extract")

#' @rdname etl_extract
#' @method etl_extract default
#' @export

etl_extract.default <- function(obj, ...) {
  # download the data from the Internet
  warning(paste0("No available methods. Did you write the method etl_extract.", class(obj)[1]), "()?")
  return(obj)
}

#' @rdname etl_extract
#' @method etl_extract etl_mtcars
#' @export

etl_extract.etl_mtcars <- function(obj, ...) {
  if (!dir.exists(obj$dir)) {
    obj$dir <- tempdir()
  }
  filename <- paste0(obj$dir, "/mtcars.csv")
  write.csv(mtcars, file = filename)
  return(obj)
}


