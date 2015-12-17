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
#' # Instantiate the etl object
#' cars <- etl("mtcars")
#' str(cars)
#'
#' # Do it step-by-step
#' cars %>%
#'   etl_extract() %>%
#'   etl_transform() %>%
#'   etl_load()
#'
#' # Note the rather imprecise data types for the columns. These are the default.
#' tbl(cars, "mtcars")
#'
#' # But you can also specify your own schema if you want
#' schema <- system.file("sql/mtcars.sqlite3", package = "etl")
#' etl_load(cars, schema)
#'
#' # notice the more specific data types
#' tbl(cars, "mtcars")


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
#' @importFrom DBI dbListTables
#' @export

etl_load.etl_mtcars <- function(obj, schema = FALSE, ...) {
  raw_dir <- paste0(attr(obj, "dir"), "/raw")
  data <- read.csv(paste0(raw_dir, "/mtcars.csv"))

  db <- verify_con(obj)
  if (is(db$con, "DBIConnection")) {
    if (schema == TRUE) {
      schema <- get_schema(db)
    }
    if (!missing(schema)) {
      message(dbRunScript(db$con, schema, ...))
    }
    if (DBI::dbWriteTable(db$con, "mtcars", value = data, row.names = FALSE, append = TRUE)) {
      message("Data was successfully written to database.")
      message(DBI::dbListTables(db$con))
    }
  } else {
    stop("Invalid connection to database.")
  }
  invisible(db)
}

get_schema <- function(con) UseMethod("get_schema")

get_schema.src_sqlite <- function(con) {
  system.file("sql/mtcars.sqlite3", package = "etl")
}

get_schema.src_mysql <- function(con) {
  system.file("sql/mtcars.mysql", package = "etl")
}

get_schema.src_postgres <- function(con) {
  system.file("sql/mtcars.psql", package = "etl")
}

