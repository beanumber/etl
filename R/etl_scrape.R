#' @title Scrape data from an online source
#'
#' @inheritParams etl_init
#' @export
#' @return the (possibly modified) \code{\link{etl}} object
#' @family etl functions
#' @examples
#'
#' require(RPostgreSQL)
#' require(dplyr)
#' db <- src_postgres("mtcars", user = "postgres", password = "postgres", host = "localhost")
#' etl_cars <- etl_connect("mtcars", db)
#' etl_cars %>%
#'  etl_init() %>%
#'  etl_scrape() %>%
#'  str()
#'

etl_scrape <- function(obj, ...) UseMethod("etl_scrape")

#' @rdname etl_scrape
#' @method etl_scrape default
#' @export

etl_scrape.default <- function(obj, ...) {
  if (!dir.exists(obj$dir)) {
    obj$dir <- tempdir()
  }
  filename <- paste0(obj$dir, "/mtcars.csv")
  write.csv(mtcars, file = filename)
  return(obj)
}


