#' @rdname etl_create
#' @export

etl_load <- function(obj, ...) UseMethod("etl_load")

#' @rdname etl_create
#' @method etl_load default
#' @export

etl_load.default <- function(obj, ...) {
  # insert data from somewhere
  warning(paste0("No available methods. Did you write the method etl_load.", class(obj)[1]), "()?")
  return(obj)
}

#' @rdname etl_create
#' @method etl_load etl_mtcars
#' @importFrom DBI dbWriteTable
#' @export

etl_load.etl_mtcars <- function(obj, ...) {
  data <- read.csv(paste0(obj$dir, "/mtcars.csv"))
  obj$push <- dbWriteTable(obj$con, "mtcars", value = data, row.names = FALSE, append = TRUE)
  return(obj)
}
