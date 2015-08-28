#' @rdname etl_create
#' @export
#' @seealso etl
#' @examples
#'
#' require(magrittr)
#' \dontrun{
#' if (require(RPostgreSQL) & require(dplyr)) {
#'   db <- src_postgres("mtcars", user = "postgres", host = "localhost")
#'   cars <- etl("mtcars", db)
#'   cars %<>% etl_create()
#'  }
#' }

etl_init <- function(obj, ...) UseMethod("etl_init")

#' @rdname etl_create
#' @method etl_init default
#' @export

etl_init.default <- function(obj, ...) {
  #  sql <- system.file("inst", package = "etl")
  message(paste0("No available methods. Did you write the method etl_init.", class(obj)[1]), "()?")
  return(obj)
}

#' @rdname etl_create
#' @method etl_init etl_mtcars
#' @export

etl_init.etl_mtcars <- function(obj, ...) {
  if (class(obj$con) == "PostgreSQLConnection") {
    sql <- system.file("sql", "mtcars.psql", package = "etl")
    obj$init <- dbRunScript(obj$con, sql)
  }
  obj$init <- TRUE
  return(obj)
}


