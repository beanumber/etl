#' Execute an SQL script
#'
#' @param conn a \code{DBIConnection-class} object
#' @param script Either a filename pointing to SQL script or
#' a character vector of length 1 containing SQL.
#' @param ... currently ignored
#' @details The SQL script file must be \code{;} delimited.
#' @return a list of results from \code{dbGetQuery} for each of the individual
#' SQL statements in \code{script}.
#' @export
#' @importFrom DBI dbSendQuery
#'
#' @examples
#' sql <- "SHOW TABLES; SELECT 1+1 as Two;"
#' sql <- system.file("sql", "mtcars.mysql", package = "etl")
#'
#' \dontrun{
#' if (require(RMySQL)) {
#'  con <- dbConnect(RMySQL::MySQL(), user = "r-user", password = "mypass", dbname = "mysql")
#'  dbRunScript(con, script = sql)
#'  dbDisconnect(con)
#' }
#' }
#'

dbRunScript <- function(conn, script, ...) {
  if (file.exists(script))
    script <- readChar(script, file.info(script)$size, useBytes = TRUE)
  # TODO: ensure SQL is safe for use before executing
  # NOTE: Already tried using DBI::dbQuoteString(),
  # but their is no default method for SQLite ->
  # https://github.com/rstats-db/RSQLite/issues/99
  script <- gsub("\n", "", script, fixed = TRUE)
  script <- unlist(strsplit(script, ";"))

  # strip out any blank lines -- these will produce an error
  good <- script[grepl(".+", script)]
  invisible(lapply(good, DBI::dbGetQuery, conn = conn))
}
