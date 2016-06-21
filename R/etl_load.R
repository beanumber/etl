#' @rdname etl_create
#'
#' @param schema Either a logical, a filename pointing to SQL schema file, or a character
#' vector containing the schema itself. If \code{schema = TRUE}, then the built-in
#' schema will be used. Note
#' that the flavor of SQL in this file must match the type of the source. That is,
#' if your object is of type \code{\link[dplyr]{src_mysql}}, then make sure that
#' the schema you specify here is written in MySQL (and not PostgreSQL). Please
#' note that SQL syntax is not, in general, completely portable. Use with caution, as this may
#' clobber any existing data you have in an existing database.
#' @export
#'
#' @examples
#'
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

etl_load <- function(obj, schema = FALSE, ...) UseMethod("etl_load")

#' @rdname etl_create
#' @method etl_load default
#' @export

etl_load.default <- function(obj, schema = FALSE, ...) {
  db <- verify_con(db)
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

etl_load.etl_mtcars <- function(obj, schema = FALSE, ...) {
  message("Loading processed data...")
  data <- utils::read.csv(paste0(attr(obj, "load_dir"), "/mtcars.csv"))

  db <- verify_con(obj)
  if (methods::is(db$con, "DBIConnection")) {
    if (schema == TRUE) {
      schema <- get_schema(db, "mtcars", "etl")
    }
    if (!missing(schema)) {
      dbRunScript(db$con, schema, ...)
    }
    if (DBI::dbWriteTable(db$con, "mtcars", value = data, row.names = FALSE, append = TRUE)) {
      message("Data was successfully written to database.")
    }
  } else {
    stop("Invalid connection to database.")
  }
  invisible(db)
}
