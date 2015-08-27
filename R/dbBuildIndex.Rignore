#' Build an index
#' 
#' \code{dbBuildIndex} uses the SQL CREATE INDEX syntax to build an index on a
#' specified column. 
#' 
#' @param conn A \code{DBIConnection} object, as produced by \code{\link{dbConnect}}
#' @param tablename The name of the table you want to build an index on
#' @param cols A character vector of column names in the table on which to build
#' the index
#' @param indexname The name of the index to be created (default NULL)
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
#' dbBuildIndex(con, "mtcars", c("cyl", "am"))
#' 
#' dbDisconnect(con)
#' }
setGeneric("dbBuildIndex", 
           def = function(conn, tablename, cols, indexname = NULL, ...) standardGeneric("dbBuildIndex")
)

#' @export
setMethod("dbBuildIndex", signature("DBIConnection", "character"), 
          function(conn, tablename, cols, indexname = NULL, ...) {
            if (is.null(indexname)) {
              indexname <- paste(paste0(cols, collapse = ""), "idx", sep = "_")
            }
            statement = paste("CREATE INDEX", indexname, "ON", tablename, 
                              "(", paste0(cols, collapse=","), ")", sep = " ")
            rs <- dbGetQuery(conn, statement, ...)
          }
)

#' @title build indexes and keys
#' 
#' @description Build indices in the airlines database
#' 
#' @param db a \code{dplyr} \code{src} or a \code{DBI} connection
#' 
#' @import dplyr
#' @importFrom DBI dbWriteTable dbGetQuery
#' @export
#' 
#' @examples
#' 
#' library(dplyr)
#' if (require(RPostgreSQL)) {
#'  # must have pre-existing database "airlines"
#'  db <- src_postgres(host = "localhost", user="postgres", password="postgres", dbname = "airlines")
#' }
#' 
#' start <- Sys.time()
#' flights <- tbl(db, "flights")
#' flights %>%
#'   filter(dest == 'BDL') %>%
#'   collect()
#' 
#' end <- Sys.time()
#' end - start
#' 
#' # build the indices
#' \dontrun{
#' buildIndices(db)
#' 
#' start <- Sys.time()
#' flights <- tbl(db, "flights")
#' flights %>%
#'   filter(dest == 'BDL') %>%
#'   collect()
#' 
#' end <- Sys.time()
#' end - start
#' }

buildIndices <- function (db) {
  if ("src" %in% class(db)) {
    con <- db$con
  } else {
    con <- db
  }
  message("Creating indices...")
  dbGetQuery(con, "ALTER TABLE airports MODIFY COLUMN faa varchar(3);")
  dbGetQuery(con, "ALTER TABLE airports ADD CONSTRAINT airports_pk PRIMARY KEY (faa);")
  dbGetQuery(con, "ALTER TABLE carriers MODIFY COLUMN carrier varchar(6);")
  dbGetQuery(con, "ALTER TABLE carriers ADD CONSTRAINT carrier_pk PRIMARY KEY (carrier);")
  dbGetQuery(con, "ALTER TABLE planes MODIFY COLUMN tailnum varchar(6);")
  dbGetQuery(con, "ALTER TABLE planes ADD CONSTRAINT tailnum_pk PRIMARY KEY (tailnum);")
  dbBuildIndex(con, "flights", c("Year", "Month", "Day"), indexname = "date_idx")
  dbBuildIndex(con, "flights", "origin")
  dbBuildIndex(con, "flights", "dest")
  dbBuildIndex(con, "flights", "carrier")
  dbBuildIndex(con, "flights", "tailnum")
  dbBuildIndex(con, "weather", "year")
  dbBuildIndex(con, "weather", "origin", indexname = "origin_widx")
  dbBuildIndex(con, "weather", "date", indexname = "date_widx")
}