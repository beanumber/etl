#' @title Push data to the DB
#'
#' @inheritParams etl_init
#' @export
#' @importFrom DBI dbWriteTable
#' @return result from \code{\link[DBI]{dbWriteTable}}
#' @family etl functions
#' @examples
#'
#' require(RPostgreSQL)
#' # connect directly
#' db <- etl_connect("mtcars", user = "postgres", password = "scem8467", host = "localhost", port = 5433)
#' etl_init(db)
#' etl_push(db)
#'

etl_push <- function (con, dir, ...) UseMethod("etl_push")

#' @rdname etl_push
#' @method etl_push default
#' @export

etl_push.default <- function (con, dir, ...) {
  data <- read.csv(paste0(dir, "/mtcars.csv"))
  dbWriteTable(con, "mtcars", value = data, row.names = TRUE, append = TRUE)
}
