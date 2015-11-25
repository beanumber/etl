#' Initialize an etl object
#'
#' @param class String specifying the class of the etl object.
#' This class determines method dispatch of \code{etl_*()} functions.
#' @return an \code{\link{etl}} object with a class specified by \code{class}.
#' @export
#' @examples
#'
#' \dontrun{
#' # define, extract, and transform a data source
#' e <- etl("mtcars")
#' e <- etl_extract(e)
#' e <- etl_transform(e)
#' str(e)
#'
#' # create a database connection
#' library(dplyr)
#' db <- src_sqlite(tempfile(fileext = ".sqlite3"), create = TRUE)
#'
#' # send data to the database
#' etl_load(e, db)
#' tbl(db, "mtcars")
#'
#' # you can also specify your own schema if you want
#' db <- src_sqlite(tempfile(fileext = ".sqlite3"), create = TRUE)
#' schema <- system.file("sql/mtcars.sqlite3", package = "etl")
#' etl_load(e, db, schema)
#'
#' # notice the more specific data types
#' tbl(db, "mtcars")
#'
#' # etl_load() will appends to existing tables when appropriate,
#' # so be careful not to duplicate rows
#' dim(tbl(db, "mtcars"))
#' #> [1] 32 12
#' etl_load(e, db)
#' dim(tbl(db, "mtcars"))
#' #> [1] 64 12
#'
#' }
#'
etl <- function(class) {
  if (missing(class)) stop("Must specify a class")
  obj <- list(data = NULL)
  structure(obj, class = c(class, "etl"))
}

#' Extract data and pull into R
#'
#' @param x an \link{etl} object.
#' @param ... arguments passed onto methods
#' @export
etl_extract <- function(x, ...) UseMethod("etl_extract")


#' @rdname etl_extract
#' @method etl_extract mtcars
etl_extract.mtcars <- function(x, ...) {
  data(mtcars, package = "datasets", envir = environment())
  x$data <- list(mtcars = mtcars)
  x
}

#' Transform data
#'
#' @param x an \link{etl} object.
#' @param ... arguments passed on to methods
#' @export
etl_transform <- function(x, ...) UseMethod("etl_transform")

#' @rdname etl_transform
#' @method etl_transform default
etl_transform.default <- function(x, ...) {
  warning("No applicable method for 'etl_transform' for an object of class",
          shQuote(class(x)[[1]]))
  x
}

#' @rdname etl_transform
#' @method etl_transform mtcars
etl_transform.mtcars <- function(x, ...) {
  x$data$mtcars$makeModel <- row.names(x$data$mtcars)
  x
}

#' Create a database schema and populate it with data
#'
#' @param x an \link{etl} object.
#' @param conn A database connection.
#' @param schema Either a filename pointing to SQL schema file or
#' a character vector containing the schema itself.
#' @param nms A character vector describing the names of table(s) to be populated.
#' This argument is ignored if schema is specified
#' (in that case, the table names in the schema are used).
#' @param ... arguments passed on to methods
#' @export
etl_load <- function(x, conn, schema, nms = names(x$data), ...)
  UseMethod("etl_load")

#' @rdname etl_load
#' @method etl_load default
#' @importFrom DBI dbWriteTable
etl_load.default <- function(x, conn, schema, nms = names(x$data), ...) {
  # verify the db connection and ensure we're dealing with a list of data frames
  conn <- verify_con(conn)
  x$data <- verify_dat(x$data)

  # create the table schema if specified
  if (!missing(schema)) {
    res <- dbRunScript(conn, schema)
    nms <- DBI::dbListTables(conn)
  }

  if (length(nms) != length(x$data))
    stop("The number of table names (nms) does not equal the number of tables.")

  # if the names already exist in the database, then append, otherwise over
  append <- nms %in% DBI::dbListTables(conn)

  res <- list()
  for (i in seq_along(x$data)) {
    # if appending, ensure columns are consistent between df and table
    dat <- x$data[[i]]
    if (append[[i]]) {
      db_fields <- DBI::dbListFields(conn, nms[[i]])
      df_fields <- names(dat)
      # if there are more df fields than table fields,
      # add new fields to the table schema
      new_fields <- setdiff(df_fields, db_fields)
      for (j in new_fields) {
        type <- DBI::dbDataType(conn, dat[, j])
        DBI::dbSendQuery(conn, sprintf("ALTER TABLE %s ADD %s %s", nms[[i]], j, type))
      }
      # if there are more table fields than df fields,
      # add those fields to the df (as missing variables)
      old_fields <- setdiff(db_fields, df_fields)
      for (j in old_fields) dat[[j]] <- NA
    }

    res <- c(res,
             DBI::dbWriteTable(conn, name = nms[[i]], value = x$data[[i]],
                               append = append[[i]], overwrite = !append[[i]],
                               row.names = FALSE, ...)
    )
  }
  invisible(res)
}


#' Clean a database
#'
#' @param x an \link{etl} object.
#' @export
etl_cleanup <- function(x, ...) UseMethod("etl_cleanup")
