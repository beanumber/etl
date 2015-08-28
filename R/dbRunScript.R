#' Execute a SQL script
#'
#' @inheritParams etl_init
#' @param con a \code{\link[DBI]{DBIConnection-class}} object
#' @param script path to a SQL script file
#' @param ... currently ignored
#' @details The SQL script file must be \code{\"} delimited.
#' @return a list of results from \code{\link[DBI]{dbGetQuery}}
#' @export
#' @author Ben Baumer
#' @importFrom stringr str_split
#' @importFrom DBI dbGetQuery

dbRunScript <- function(con, script, ...) {
  if (!file.exists(script)) {
    stop("The specified file does not exist.")
  }
  sql_text <- paste0(readLines(script), collapse = "")
  sql <- unlist(stringr::str_split(sql_text, pattern = ";"))
  sapply(sql, DBI::dbGetQuery, conn = con)
}
