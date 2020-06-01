#' Execute an SQL script
#'
#' @param conn a \code{\link[DBI]{DBIConnection-class}} object
#' @param script Either a filename pointing to an SQL script or
#' a character vector of length 1 containing SQL.
#' @param echo print the SQL commands to the output?
#' @param ... arguments passed to \code{\link[DBI]{dbExecute}}
#' @details The SQL script file must be \code{;} delimited.
#' @return a list of results from \code{dbExecute} for each of the individual
#' SQL statements in \code{script}.
#' @export
#'
#' @examples
#' sql <- "SHOW TABLES; SELECT 1+1 as Two;"
#' sql2 <- system.file("sql", "mtcars.mysql", package = "etl")
#' sql3 <- "SELECT * FROM user WHERE user = 'mysql';SELECT * FROM user WHERE 't' = 't';"
#'
#' if (require(RSQLite)) {
#'   con <- dbConnect(RSQLite::SQLite())
#'   dbRunScript(con, "SELECT 1+1 as Two; VACUUM; ANALYZE;")
#' }
#' \dontrun{
#' if (require(RMySQL)) {
#'  con <- dbConnect(RMySQL::MySQL(), default.file = path.expand("~/.my.cnf"),
#'    group = "client", user = NULL, password = NULL, dbname = "mysql", host = "127.0.0.1")
#'  dbRunScript(con, script = sql)
#'  dbRunScript(con, script = sql2)
#'  dbRunScript(con, script = sql3)
#'  dbDisconnect(con)
#' }
#' }
#'

dbRunScript <- function(conn, script, echo = FALSE, ...) {
  if (file.exists(script)) {
    message(paste0("Initializing DB using SQL script ", basename(script)))
    sql <- readChar(script, file.info(script)$size, useBytes = TRUE)
  } else {
    sql <- script
  }

  sql_lines <- unlist(strsplit(sql, "\n"))
  # strip out any blank lines -- these will produce an error
  sql_lines <- sql_lines[grepl("[A-Za-z0-9);]+", sql_lines)]
  # filter out comments
  sql_lines <- sql_lines[!grepl("^--", sql_lines)]
  sql_lines <- sql_lines[!grepl("^/\\*", sql_lines)]

  sql_rebuild <- paste(sql_lines, collapse = " ")
  sql_cmds <- unlist(strsplit(sql_rebuild, ";"))

  good <- DBI::SQL(sql_cmds)
  if (echo) {
    print(good)
  }
  lapply(good, DBI::dbExecute, conn = conn, ... = ...)
}
