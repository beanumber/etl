#' etl_mtcars-class
#'
#' @export
#' @importClassesFrom DBI DBIConnection
#' @importClassesFrom RPostgreSQL PostgreSQLConnection
#'
setClass("etl_mtcars", contains = "DBIConnection")

setIs("etl_mtcars", "PostgreSQLConnection",
      coerce = function(from) from,
      replace= function(from, value) {
        from <- value; from })
