#' @title Process raw data into a format suitable for DB insert
#'
#' @inheritParams etl_init
#' @export
#' @return a path to the directory
#' @seealso etl_init
#' @family etl functions
#' @examples
#'
#' myDir <- "~/Desktop"
#' etl_scrape(dir = myDir)
#' etl_process()

etl_process <- function (dir, ...) UseMethod("etl_process")

#' @rdname etl_process
#' @method etl_process default
#' @export

etl_process.default <- function (dir, ...) {
  if (!dir.exists(dir)) {
    stop("Directory does not exist! Please specify a valid path to the raw data.")
  }
  # load the data and process it if necessary
  return(dir)
}


