#' @title Create and populate a database from an online source
#'
#' @inheritParams etl_init
#' @export
#' @return the result of \code{\link{etl_update}}
#' @family etl functions
#' @examples
#'
#' require(magrittr)
#' if (require(RSQLite) & require(dplyr)) {
#'  db <- src_sqlite(path = tempfile(), create = TRUE)
#'  cars <- etl_connect("mtcars", db)
#'  cars %<>% etl_create()
#'  db %>%
#'    tbl(from = "mtcars") %>%
#'    group_by(cyl) %>%
#'    summarise(N = n(), meanMPG = mean(mpg))
#' }

etl_create <- function(obj, ...) UseMethod("etl_create")

#' @rdname etl_create
#' @method etl_create default
#' @export

etl_create.default <- function(obj, ...) {
  if (is.null(obj$init)) {
    obj <- etl_init(obj, ...)
  }
  etl_update(obj, ...)
}
