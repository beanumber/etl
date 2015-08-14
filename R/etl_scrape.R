#' @title Scrape data from an online source
#'
#' @inheritParams etl_init
#' @export
#' @return a path to the directory
#' @family etl functions
#' @examples
#'
#' etl_scrape(dir = "~/Desktop")
#'

etl_scrape <- function (dir = tempdir(), ...) UseMethod("etl_scrape")

#' @rdname etl_scrape
#' @method etl_scrape default
#' @export

etl_scrape.default <- function (dir = tempdir(), ...) {
  if (!dir.exists(dir)) {
    dir <- tempdir()
  }
  filename <- paste0(dir, "/mtcars.csv")
  write.csv(mtcars, file = filename)
  return(dir(dir))
}


