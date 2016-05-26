#' Test an etl object
#'
#' @export
#' @param x an object

is.etl <- function(x) inherits(x, "etl")

#' @import RSQLite
#' @import dplyr

# ensure we have a valid database connection
verify_con <- function(x, dir = tempdir()) {
  if (!inherits(x, "src")) {
    sqlite_file <- tempfile(fileext = ".sqlite3", tmpdir = dir)
    message(paste("Not a valid src. Creating a src_sqlite for you at", sqlite_file))
    x <- dplyr::src_sqlite(path = sqlite_file, create = TRUE)
  }
  x
}

# make sure we're dealing with a _list of_ data frames
# verify_dat <- function(dat) {
#   if (is.data.frame(dat)) dat <- list(dat)
#   is_df <- vapply(dat, is.data.frame, logical(1))
#   if (!all(is_df))
#     warning("Detected data objects that aren't data frames.\n",
#             "These will not be exported to the database.")
#   dat[is_df]
# }

#' Retrieve a pre-defined schema
#'
#' @description If the table definitions are at all non-trivial,
#' you may wish to include a pre-defined table schema. This function
#' will retrieve it.
#'
#' @param con A database connection
#' @param schema_name The name of the schema
#' @param pkg The package defining the schema
#' @param ext The file extension used for the SQL schema file
#' @param ... Currently ignored
#'
#' @export
#' @examples
#'
#' cars <- etl("mtcars")
#' get_schema(cars, "mtcars", "etl")

get_schema <- function(con, schema_name, pkg, ext = NULL, ...) UseMethod("get_schema")

#' @export
#' @rdname get_schema
#' @method get_schema default

get_schema.default <- function(con, schema_name, pkg, ext = NULL, ...) {
  sql <- paste0("sql/", schema_name, ".", ext)
  return(system.file(sql, package = pkg, mustWork = TRUE))
}

#' @export
#' @rdname get_schema
#' @method get_schema src_sqlite

get_schema.src_sqlite <- function(con, schema_name, pkg, ext = NULL, ...) {
  NextMethod(ext = "sqlite3")
}


#' @export
#' @rdname get_schema
#' @method get_schema src_mysql

get_schema.src_mysql <- function(con, schema_name, pkg, ...) {
  NextMethod(ext = "mysql")
}

#' @export
#' @rdname get_schema
#' @method get_schema src_postgres
#'
get_schema.src_postgres <- function(con, schema_name, pkg, ...) {
  NextMethod(ext = "psql")
}

#' Download only those files that don't already exist
#' @param obj an \code{\link{etl}} object
#' @param src a character vector of paths to filenames that you want to have
#' @param ... arguments passed to \code{\link[utils]{download.file}}
#' @details Downloads only those files in \code{src} that are not already present
#' the \code{raw_dir} attribute of \code{obj}
#' files in \code{src} do not already exist in \code{dir}.
#' @export
smart_download <- function(obj, src, ...) {
  lcl <- paste0(attr(obj, "raw_dir"), "/", basename(src))
  missing <- !file.exists(lcl)
  mapply(utils::download.file, src[missing], lcl[missing])
}


