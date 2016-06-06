#' Execute an SQL script
#'
#' @param conn a \code{\link[DBI]{DBIConnection-class}} object
#' @param script Either a filename pointing to an SQL script or
#' a character vector of length 1 containing SQL.
#' @param echo print the SQL commands to the output?
#' @param ... arguments passed to \code{\link[DBI]{dbGetQuery}}
#' @details The SQL script file must be \code{;} delimited. This will function will
#' be superseded by \code{dbExecute} in the next release of \pkg{DBI}.
#' See \url{https://github.com/rstats-db/DBI/pull/109}.
#' @return a list of results from \code{dbGetQuery} for each of the individual
#' SQL statements in \code{script}.
#' @importFrom DBI SQL
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
#'    group = "client",user = NULL, password = NULL, dbname = "mysql")
#'  dbRunScript(con, script = sql)
#'  dbRunScript(con, script = sql2)
#'  dbRunScript(con, script = sql3)
#'  dbDisconnect(con)
#' }
#' }
#'

dbRunScript <- function(conn, script, echo = FALSE, ...) {
  if (file.exists(script)) {
    message(paste0("Loading SQL script at ", script))
    sql <- readChar(script, file.info(script)$size, useBytes = TRUE)
  } else {
    sql <- script
  }

  sql <- gsub("\n", " ", sql, fixed = TRUE)
  sql <- unlist(strsplit(sql, ";"))

  # strip out any blank lines -- these will produce an error
  good <- sql[grepl("\\w+", sql)]
  good <- DBI::SQL(good)
  if (echo) {
    print(good)
  }
  lapply(good, dbGetQuery, conn = conn, ... = ...)
}
