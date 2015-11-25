#' Execute an SQL script
#'
#' @param con a \code{DBIConnection-class} object
#' @param script path to an SQL script file
#' @param ... currently ignored
#' @details The SQL script file must be \code{;} delimited.
#' @return a list of results from \code{dbGetQuery} for each of the individual
#' SQL statements in \code{script}.
#' @export
#' @author Ben Baumer
#' @importFrom stringr str_split
#' @importFrom DBI dbGetQuery
#'
#' @examples
#' sql <- "SHOW TABLES; SELECT 1+1 as Two;"
#' tmpfile <- tempfile()
#' write(sql, file = tmpfile)
#'
#' \dontrun{
#' if (require(RMySQL)) {
#'  con <- dbConnect(RMySQL::MySQL(), user = "r-user", password = "mypass", dbname = "mysql")
#'  dbRunScript(con, script = tmpfile)
#'  dbDisconnect(con)
#' }
#' }
#'

dbRunScript <- function(con, script, ...) {
  if (!file.exists(script)) {
    stop("The specified file does not exist.")
  }
  sql_text <- paste0(readLines(script), collapse = " ")
  sql <- unlist(stringr::str_split(sql_text, pattern = ";"))
  # strip out any blank lines -- these will produce an error
  good <- sql[grepl(".+", sql)]
  sapply(good, DBI::dbGetQuery, conn = con)
}
