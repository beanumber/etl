#' @rdname etl_create
#' @param init a logical indicating whether the database should be initialized
#' before attempting to load the data into it. Use with caution, as this may
#' clobber any existing data you have in an existing database.
#' @export

etl_load <- function(obj, init = FALSE, ...) UseMethod("etl_load")

#' @rdname etl_create
#' @method etl_load default
#' @export

etl_load.default <- function(obj, init = FALSE, ...) {
  db <- verify_con(db)
  # insert data from somewhere
  warning(paste0("No available methods. Did you write the method etl_load.", class(obj)[1]), "()?")
  return(obj)
}

#' @rdname etl_create
#' @method etl_load etl_mtcars
#' @importFrom DBI dbWriteTable
#' @importFrom DBI dbListTables
#' @export

etl_load.etl_mtcars <- function(obj, init = FALSE, ...) {
  raw_dir <- paste0(attr(obj, "dir"), "/raw")
  data <- read.csv(paste0(raw_dir, "/mtcars.csv"))

  db <- verify_con(obj)
  if (is(obj$con, "DBIConnection")) {
    if (init) {
      etl_init(obj)
    }
    if (DBI::dbWriteTable(obj$con, "mtcars", value = data, row.names = FALSE, append = TRUE)) {
      message("Data was successfully written to database.")
      message(DBI::dbListTables(obj$con))
    }
  } else {
    stop("Invalid connection to database.")
  }
  return(obj)
}


#' @rdname etl_create
#' @inheritParams etl_load
#' @export
#' @seealso etl
#' @examples
#'
#' \dontrun{
#' if (require(RPostgreSQL) & require(dplyr)) {
#'   db <- src_postgres("mtcars", user = "postgres", host = "localhost")
#'   cars <- etl("mtcars")
#'   cars %>% etl_init()
#'  }
#' }

etl_init <- function(obj, ...) UseMethod("etl_init")

#' @rdname etl_create
#' @method etl_init default
#' @export

etl_init.default <- function(obj, ...) {
  #  sql <- system.file("inst", package = "etl")
  message(paste0("No available methods. Did you write the method etl_init.", class(obj)[1]), "()?")
  return(obj)
}

#' @rdname etl_create
#' @method etl_init etl_mtcars
#' @export

etl_init.etl_mtcars <- function(obj, ...) {
  if (class(obj$con) == "PostgreSQLConnection") {
    sql <- system.file("sql", "mtcars.psql", package = "etl")
    message(dbRunScript(obj$con, sql))
  }
  obj$init <- TRUE
  return(obj)
}


