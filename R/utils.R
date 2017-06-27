if(getRversion() >= "2.15.1")  utils::globalVariables(".")

#' @import dplyr

# ensure we have a valid database connection
verify_con <- function(x, dir = tempdir()) {
  if (!inherits(x, "src")) {
    sqlite_file <- tempfile(fileext = ".sqlite3", tmpdir = dir)
    message("Not a valid src. Creating a src_sqlite for you at:")
    message(sqlite_file)
    x <- dplyr::src_sqlite(path = sqlite_file, create = TRUE)
  }
  x
}

# make sure we're dealing with a _list of_ data frames
# verify_dat <- function(dat) {
#   if (is.data.frame(dat)) dat <- list(dat)
#   is_df <- vapply(dat, is.data.frame, logical(1))
#   if (!all(is_df))
#     warning("Detected data objects that aren't data frames.\n",
#             "These will not be exported to the database.")
#   dat[is_df]
# }


#' Ensure that years and months are within a certain time span
#' @param years a numeric vector of years
#' @param months a numeric vector of months
#' @param begin the earliest valid date, defaults to the UNIX epoch
#' @param end the most recent valid date, defaults to today
#' @importFrom lubridate ymd
#' @details Often, a data source will \code{begin} and \code{end} at
#' known points in time. At the same time, many data sources are divided
#' into monthly archives. Given a set of \code{years} and \code{months},
#' any combination of which should be considered valid, this function will
#' return a \code{\link{data.frame}} in which each row is one of those
#' valid year-month pairs. Further, if the optional \code{begin} and
#' \code{end} arguments are specified, the rows will be filter to lie
#' within that time interval. Furthermore, the first and last day of
#' each month are computed.
#' @return a \code{\link{data.frame}} with four variables: \code{year},
#' \code{month}, \code{month_begin} (the first day of the month), and
#' \code{month_end} (the last day of the month).
#' @export
#' @examples
#'
#' valid_year_month(years = 1999:2001, months = c(1:3, 7))
#'
#' # Mets in the World Series since the UNIX epoch
#' mets_ws <- c(1969, 1973, 1986, 2000, 2015)
#' valid_year_month(years = mets_ws, months = 10)
#'
#' # Mets in the World Series during the Clinton administration
#' if (require(ggplot2)) {
#'   clinton <- filter(presidential, name == "Clinton")
#'   valid_year_month(years = mets_ws, months = 10,
#'     begin = clinton$start, end = clinton$end)
#' }
#'
valid_year_month <- function(years, months,
                             begin = "1970-01-01", end = Sys.Date()) {
  years <- as.numeric(years)
  months <- as.numeric(months)
  begin <- as.Date(begin)
  end <- as.Date(end)

  valid_months <- data.frame(expand.grid(years, months)) %>%
    rename_(year = ~Var1, month = ~Var2) %>%
    mutate_(month_begin = ~lubridate::ymd(paste(year, month,
                                                "01", sep = "/"))) %>%
    mutate_(month_end = ~lubridate::ymd(
      ifelse(month == 12, paste(year + 1, "01/01", sep = "/"),
                          paste(year, month + 1, "01", sep = "/"))) - 1) %>%
    filter_(~year > 0 & month >= 1 & month <= 12) %>%
    filter_(~month_begin >= begin & month_begin <= end) %>%
    arrange_(~month_begin)
  return(valid_months)
}



#' Match year and month vectors to filenames
#' @description Match year and month vectors to filenames
#' @inheritParams extract_date_from_filename
#' @param years a numeric vector of years
#' @param months a numberic vector of months
#' @return a character vector of \code{files} that match the \code{pattern}, \code{year}, and \code{month} arguments
#' @importFrom lubridate year month
#' @export
#' @examples
#' \dontrun{
#' if (require(airlines)) {
#'   airlines <- etl("airlines", dir = "~/dumps/airlines") %>%
#'     etl_extract(year = 1987)
#'   summary(airlines)
#'   match_files_by_year_months(list.files(attr(airlines, "raw_dir")),
#'     pattern = "On_Time_On_Time_Performance_%Y_%m.zip"), year = 1987)
#' }
#' }

match_files_by_year_months <- function(files, pattern,
                                       years = as.numeric(
                                         format(Sys.Date(), '%Y')),
                                       months = 1:12, ...) {
  if (length(files) < 1) {
    return(NULL)
  }
  file_df <- data.frame(filename = files,
                        file_date = extract_date_from_filename(files,
                                                               pattern)) %>%
    mutate_(file_year = ~lubridate::year(file_date),
            file_month = ~lubridate::month(file_date))
  valid <- valid_year_month(years, months)
  good <- file_df %>%
    left_join(valid, by = c("file_year" = "year", "file_month" = "month")) %>%
    filter_(~!is.na(month_begin))
  return(as.character(good$filename))
}

#' @description Extracts a date from filenames
#' @param files a character vector of filenames
#' @param pattern a regular expression to be passed to \code{\link[lubridate]{fast_strptime}}
#' @param ... arguments passed to \code{\link[lubridate]{fast_strptime}}
#' @return a vector of \code{\link{POSIXct}} dates matching the pattern
#' @importFrom lubridate fast_strptime days
#' @export
#' @rdname match_files_by_year_months

extract_date_from_filename <- function(files, pattern, ...) {
  if (length(files) < 1) {
    return(NULL)
  }
  files %>%
    basename() %>%
    lubridate::fast_strptime(format = pattern, ...) %>%
    # why does it always return the previous day?
    as.Date() + lubridate::days(1)
}

#' Wipe out all tables in a database
#' @details Finds all tables within a database and removes them
#' @inheritParams DBI::dbRemoveTable
#' @importFrom DBI dbRemoveTable
#' @export

dbWipe <- function(conn, ...) {
  x <- DBI::dbListTables(conn)
  if (length(x) > 0) {
    lapply(x, DBI::dbRemoveTable, conn = conn, ... = ...)
  }
}

#' Connect to local MySQL Server using ~/.my.cnf
#' @param dbname name of the local database you wish to connect to. Default is
#' \code{test}, as in \code{\link[RMySQL]{mysqlHasDefault}}.
#' @param groups section of \code{~/.my.cnf} file. Default is \code{rs-dbi} as in
#' \code{\link[RMySQL]{mysqlHasDefault}}
#' @param ... arguments passed to \code{\link[dplyr]{src_mysql}}
#' @export
#' @seealso \code{\link[dplyr]{src_mysql}}, \code{\link[RMySQL]{mysqlHasDefault}}
#' @examples
#' if (require(RMySQL) && mysqlHasDefault()) {
#'   # connect to test database using rs-dbi
#'   db <- src_mysql_cnf()
#'   class(db)
#'   db
#'   # connect to another server using the 'client' group
#'   src_mysql_cnf(groups = "client")
#' }
src_mysql_cnf <- function(dbname = "test", groups = "rs-dbi", ...) {
  config_file_path <- file.path("~", ".my.cnf")
  if (!file.exists(config_file_path)) {
    warning("No MySQL config file found...trying anyway...")
    tryCatch({
      dplyr::src_mysql(groups = groups, dbname = dbname,
                       user = NULL, password = NULL, ...)
    }, error = function(...) {
        message("Could not connect to mysql source.")
        return(FALSE)
    })
  } else {
    dplyr::src_mysql(default.file = config_file_path,
              groups = groups, dbname = dbname,
              user = NULL, password = NULL, ...)
  }
}

#' Return the datbaase type for an ETL or DBI connection
#' @param obj and \code{\link{etl}} or \code{\link[DBI]{DBIConnection-class}} object
#' @param ... currently ignored
#' @export
#' @examples
#' if (require(RMySQL) && mysqlHasDefault()) {
#'   # connect to test database using rs-dbi
#'   db <- src_mysql_cnf()
#'   class(db)
#'   db
#'   # connect to another server using the 'client' group
#'   db_type(db)
#'   db_type(db$con)
#' }

db_type <- function(obj, ...) UseMethod("db_type")

#' @rdname db_type
#' @method db_type src_dbi
#' @export

db_type.src_dbi <- function(obj, ...) {
  db_type(obj$con)
}

#' @rdname db_type
#' @importFrom utils head
#' @method db_type DBIConnection
#' @export

db_type.DBIConnection <- function(obj, ...) {
  class(obj) %>%
    gsub(pattern = "Connection", replacement = "", x = .) %>%
    tolower() %>%
    utils::head(1)
}

