#' @rdname etl_create
#' @export

etl_update <- function(obj, ...) UseMethod("etl_update")

#' @rdname etl_create
#' @method etl_update default
#' @importFrom magrittr %<>%
#' @importFrom magrittr %>%
#' @export

etl_update.default <- function(obj, ...) {
  obj %<>%
    etl_extract(...) %>%
    etl_transform(...) %>%
    etl_load(...)
  if (!is.null(obj$push)) {
    etl_cleanup(obj, ...)
  } else {
    warning("Unable to push data to the database?")
  }
  return(obj)
}
