#' @rdname etl_create
#' @export
#' @examples
#' cars <- etl("mtcars")
#' # Do it step-by-step
#' cars %>%
#'   etl_extract() %>%
#'   etl_transform() %>%
#'   etl_load()
#'
#' # Note the somewhat imprecise data types for the columns. These are the default.
#' tbl(cars, "mtcars")
#'
#' # But you can also specify your own schema if you want
#' schema <- system.file("sql/mtcars.sqlite3", package = "etl")
#' etl_load(cars, schema)

etl_load <- function(obj, ...) UseMethod("etl_load")

#' @rdname etl_create
#' @method etl_load default
#' @export

etl_load.default <- function(obj, ...) {
  obj <- verify_con(obj)
  # insert data from somewhere
  warning(paste0("No available methods. Did you write the method etl_load.", class(obj)[1]), "()?")
  invisible(obj)
}

#' @rdname etl_create
#' @method etl_load etl_mtcars
#' @importFrom DBI dbWriteTable
#' @importFrom utils read.csv
#' @importFrom methods is
#' @export

etl_load.etl_mtcars <- function(obj, ...) {
  message("Loading processed data...")
  data <- utils::read.csv(paste0(attr(obj, "load_dir"), "/mtcars.csv"))

  obj <- verify_con(obj)
  if (DBI::dbWriteTable(obj$con, "mtcars", value = data, row.names = FALSE, append = TRUE)) {
    message("Data was successfully written to database.")
  }
  invisible(obj)
}

#' @rdname etl_create
#' @param script either a vector of SQL commands to be executed, or
#' a file path as a character vector containing an SQL initialization script.
#' If \code{NULL} (the default), then the appropriate built-in
#' schema will be fetched by \code{\link{get_schema}}, if it exists. Note
#' that the flavor of SQL in this file must match the type of the source. That is,
#' if your object is of type \code{\link[dplyr]{src_mysql}}, then make sure that
#' the schema you specify here is written in MySQL (and not PostgreSQL). Please
#' note that SQL syntax is not, in general, completely portable. Use with caution, as this may
#' clobber any existing data you have in an existing database.
#' @export
etl_init <- function(obj, script = NULL, ...) UseMethod("etl_init")

#' @rdname etl_create
#' @method etl_init default
#' @export
etl_init.default <- function(obj, script = NULL, ...) {
  obj <- verify_con(obj)
  if (methods::is(obj$con, "DBIConnection")) {
    dbRunScript(obj$con, script, ...)
  } else {
    stop("Invalid connection to database.")
  }
  invisible(obj)
}

#' @rdname etl_create
#' @method etl_init etl_mtcars
#' @importFrom DBI dbRemoveTable
#' @export
#' @examples
#'
#' cars <- etl("mtcars")
#' cars %>%
#'   etl_init()
#' cars %>%
#'   etl_init(script = sql("CREATE TABLE IF NOT EXISTS mtcars_alt (id INTEGER);"))
#' init_script <- get_schema(cars, "mtcars", "etl")
#' cars %>%
#'   etl_init(script = init_script, echo = TRUE)
#' src_tbls(cars)
#'
etl_init.etl_mtcars <- function(obj, script = NULL, ...) {
  if (is.null(script)) {
    if ("mtcars" %in% src_tbls(obj)) {
      DBI::dbRemoveTable(obj$con, "mtcars")
    }
    return(invisible(obj))
  }
  if (is.character(script)) {
    schema <- script
  } else {
    schema <- get_schema(obj, "mtcars", "etl")
  }
  NextMethod(script = schema)
}
