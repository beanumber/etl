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
#' db <- src_postgres("mtcars", user = "postgres", host = "localhost")
#' etl_cars <- etl_connect("mtcars", db)
#' etl_cars %>%
#'  etl_extract() %>%
#'  etl_transform() %>%
#'  str()
#' }

etl_transform <- function(obj, ...) UseMethod("etl_transform")

#' @rdname etl_transform
#' @method etl_transform default
#' @export

etl_transform.default <- function(obj, ...) {
  # load the data and process it if necessary
  message(paste0("No available methods. Did you write the method etl_transform.", class(obj)[1]), "()?")
  return(obj)
}

#' @rdname etl_transform
#' @method etl_transform etl_mtcars
#' @export

etl_transform.etl_mtcars <- function(obj, ...) {
  if (!dir.exists(obj$dir)) {
    stop("Directory does not exist! Please specify a valid path to the raw data.")
  }
  # load the data and process it if necessary
  return(obj)
}


