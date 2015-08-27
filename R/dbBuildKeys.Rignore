
#' Build a Key
#' 
#' \code{dbBuildKey} uses the SQL ALTER TABLE syntax to build a key on a
#' specified column. 
#' 
#' @param conn A \code{DBIConnection} object, as produced by \code{\link{dbConnect}}
#' @param tablename The name of the table you want to build an index on
#' @param cols A character vector of column names in the table on which to build
#' the index
#' @param keyname The name of the key to be created (default NULL)
#' @param ... arguments passed to \code{\link{dbGetQuery}}
#' @family connection methods
#' @importFrom DBI dbGetQuery dbConnect
#' @export
#' @examples
#' if (require("RSQLite")) {
#' con <- dbConnect(RSQLite::SQLite(), ":memory:")
#' 
#' dbWriteTable(con, "mtcars", mtcars)
#' dbGetQuery(con, "SELECT * FROM mtcars")
#' 
#' dbBuildKey(con, "mtcars", c("cyl", "am"))
#' 
#' dbDisconnect(con)
#' }
setGeneric("dbBuildKey", 
           def = function(conn, tablename, cols, keyname = NULL, ...) standardGeneric("dbBuildKey")
)

#' @export
setMethod("dbBuildKey", signature("DBIConnection", "character"), 
          function(conn, tablename, cols, keytype = NULL, keyname = NULL, ...) {
#             if (!keytype %in% c(NULL, "PRIMARY", "UNIQUE")) {
#               keytype <- NULL
#             }
#             if (is.null(keyname)) {
#               keyname <- paste(paste0(cols, collapse = ""), "key", sep = "_")
#             }
#             statement = paste("ALTER TABLE", tablename, "ADD", keytype, "KEY", keyname, 
#                               "(", paste0(cols, collapse=","), ")", sep = " ")
#             rs <- dbGetQuery(conn, statement, ...)
          }
)
