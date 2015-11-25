is.etl <- function(x) inherits(x, "etl")

# ensure we have a valid database connection
verify_con <- function(x) {
  x <- if (inherits(x, "src")) x$con else x
  if (!is(x, "DBIConnection"))
    stop("Could not make connection to database.", call. = FALSE)
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


#' Execute an arbitrary SQL script
#'
#' @param conn a \code{\link[DBI]{DBIConnection-class}} object
#' @param script Either a filename pointing to SQL script or
#' a character vector of length 1 containing SQL.
#' @details The SQL script file must be \code{\"} delimited.
#' @importFrom DBI dbSendQuery

# how the hell doesn't DBI already support multi-line SQL statements?
dbRunScript <- function(conn, script) {
  if (file.exists(script))
    script <- readChar(script, file.info(script)$size, useBytes = TRUE)
  # TODO: ensure SQL is safe for use before executing
  # NOTE: Already tried using DBI::dbQuoteString(),
  # but their is no default method for SQLite ->
  # https://github.com/rstats-db/RSQLite/issues/99
  script <- gsub("\n", "", script, fixed = TRUE)
  script <- unlist(strsplit(script, ";"))
  invisible(lapply(script, DBI::dbSendQuery, conn = conn))
}

