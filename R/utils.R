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

#' Retrieve a pre-defined schema
#'
#' @description If the table definitions are at all non-trivial,
#' you may wish to include a pre-defined table schema. This function
#' will retrieve it.
#'
#' @param con A database connection
#' @param schema_name The name of the schema
#' @param pkg The package defining the schema
#' @param ext The file extension used for the SQL schema file
#' @param ... Currently ignored
#'
#' @export
#' @examples
#'
#' cars <- etl("mtcars")
#' get_schema(cars, "mtcars", "etl")

get_schema <- function(con, schema_name, pkg, ext = NULL, ...) UseMethod("get_schema")

#' @export
#' @rdname get_schema
#' @method get_schema default

get_schema.default <- function(con, schema_name, pkg, ext = NULL, ...) {
  sql <- paste0("sql/", schema_name, ".", ext)
  return(system.file(sql, package = pkg, mustWork = TRUE))
}

#' @export
#' @rdname get_schema
#' @method get_schema src_sqlite

get_schema.src_sqlite <- function(con, schema_name, pkg, ext = NULL, ...) {
  NextMethod(ext = "sqlite3")
}


#' @export
#' @rdname get_schema
#' @method get_schema src_mysql

get_schema.src_mysql <- function(con, schema_name, pkg, ...) {
  NextMethod(ext = "mysql")
}

#' @export
#' @rdname get_schema
#' @method get_schema src_postgres
#'
get_schema.src_postgres <- function(con, schema_name, pkg, ...) {
  NextMethod(ext = "psql")
}

#' Download only those files that don't already exist
#' @param obj an \code{\link{etl}} object
#' @param src a character vector of URLs that you want to download
#' @param ... arguments passed to \code{\link[utils]{download.file}}
#' @details Downloads only those files in \code{src} that are not already present in
#' the directory specified by the \code{raw_dir} attribute of \code{obj}.
#' @author idiom courtesy of Hadley Wickham
#' @export
smart_download <- function(obj, src, ...) {
  lcl <- paste0(attr(obj, "raw_dir"), "/", basename(src))
  missing <- !file.exists(lcl)
  mapply(utils::download.file, src[missing], lcl[missing], ... = ...)
}

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
valid_year_month <- function(years, months, begin = "1970-01-01", end = Sys.Date()) {
  years <- as.numeric(years)
  months <- as.numeric(months)
  begin <- as.Date(begin)
  end <- as.Date(end)

  valid_months <- data.frame(expand.grid(years, months)) %>%
    rename_(year = ~Var1, month = ~Var2) %>%
    mutate_(month_begin = ~lubridate::ymd(paste(year, month, "01", sep = "/"))) %>%
    mutate_(month_end = ~lubridate::ymd(
      ifelse(month == 12, paste(year + 1, "01/01", sep = "/"),
                          paste(year, month + 1, "01", sep = "/"))) - 1) %>%
    filter_(~year > 0 & month >= 1 & month <= 12) %>%
    filter_(~month_begin >= begin & month_begin <= end) %>%
    arrange_(~month_begin)
  return(valid_months)
}



