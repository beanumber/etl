#' Test an etl object
#'
#' @export
#' @param x an object

is.etl <- function(x) inherits(x, "etl")

#' @import RSQLite
#' @import dplyr

# ensure we have a valid database connection
verify_con <- function(x) {
  if (!inherits(x, "src")) {
    sqlite_file <- tempfile(fileext = ".sqlite3")
    message(paste("Not a valid src. Creating a src_sqlite for you at", sqlite_file))
    x <- dplyr::src_sqlite(path = sqlite_file, create = TRUE)
  }
#   x$con else x
#   if (!is(x, "DBIConnection"))
#     stop("Could not make connection to database.", call. = FALSE)
  x
}

# make sure we're dealing with a _list of_ data frames
verify_dat <- function(dat) {
  if (is.data.frame(dat)) dat <- list(dat)
  is_df <- vapply(dat, is.data.frame, logical(1))
  if (!all(is_df))
    warning("Detected data objects that aren't data frames.\n",
            "These will not be exported to the database.")
  dat[is_df]
}


#' Execute arbitrary SQL code without forcing a data frame to be returned
#'
#' @description Execute arbitrary SQL code without forcing a data frame to be returned
#'
#' @inheritParams DBI::dbGetQuery
#' @param echo show the SQL statement as messages?
#'
#' @import DBI
#' @export
dbGetQuery_safe <- function(conn, statement, echo = FALSE, ...) {
            if (echo) {
              message(statement)
            }
            rs <- dbSendQuery(conn, statement, ...)
            on.exit(dbClearResult(rs))

            tryCatch(df <- dbFetch(rs, n = -1, ...), error = function(c) {
#              message(c)
              df <- NULL
            })
            if (!dbHasCompleted(rs)) {
              warning("Pending rows", call. = FALSE)
            }

            df
          }
