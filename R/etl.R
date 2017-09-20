#' Initialize an \code{etl} object
#'
#' @description Initialize an \code{etl} object
#'
#' @param x the name of the \code{etl} package that you wish to populate with data.
#' This determines the class of the resulting \code{\link{etl}} object, which
#' determines method dispatch of \code{etl_*()} functions. There is no default,
#' but you can use \code{mtcars} as an test example.
#' @param db a database connection that inherits from \code{\link[dplyr]{src_dbi}}. It is
#' NULL by default, which results in a \code{\link[dplyr]{src_sqlite}} connection
#' being created in \code{dir}.
#' @param dir a directory to store the raw and processed data files
#' @param ... arguments passed to methods (currently ignored)
#' @details A constructor function that instantiates an \code{\link{etl}} object.
#' An \code{\link{etl}} object extends a \code{\link[dplyr]{src_dbi}} object.
#' It also has attributes for:
#' \describe{
#'  \item{pkg}{the name of the \code{\link{etl}} package corresponding to the data source}
#'  \item{dir}{the directory where the raw and processed data are stored}
#'  \item{raw_dir}{the directory where the raw data files are stored}
#'  \item{load_dir}{the directory where the processed data files are stored}
#'  }
#' Just like any \code{\link[dplyr]{src_dbi}} object, an \code{\link{etl}} object
#' is a data source backed by an SQL database. However, an \code{\link{etl}} object
#' has additional functionality based on the presumption that the SQL database
#' will be populated from data files stored on the local hard disk. The ETL functions
#' documented in \code{\link{etl_create}} provide the necessary functionality
#' for \strong{extract}ing data from the Internet to \code{raw_dir},
#' \strong{transform}ing those data
#' and placing the cleaned up data (usually in CSV format) into \code{load_dir},
#' and finally \strong{load}ing the clean data into the SQL database.
#' @return For \code{\link{etl}}, an object of class \code{etl_x} and
#' \code{\link{etl}} that inherits
#' from \code{\link[dplyr]{src_dbi}}
#' @export
#' @seealso \code{\link{etl_create}}
#' @examples
#'
#' # Instantiate the etl object
#' cars <- etl("mtcars")
#' str(cars)
#' is.etl(cars)
#' summary(cars)
#'
#' \dontrun{
#' # connect to a PostgreSQL server
#' if (require(RPostgreSQL)) {
#'  db <- src_postgres("mtcars", user = "postgres", host = "localhost")
#'  cars <- etl("mtcars", db)
#' }
#' }
#'
#' # Do it step-by-step
#' cars %>%
#'   etl_extract() %>%
#'   etl_transform() %>%
#'   etl_load()
#' src_tbls(cars)
#' cars %>%
#'   tbl("mtcars") %>%
#'   group_by(cyl) %>%
#'   summarize(N = n(), mean_mpg = mean(mpg))
#'
#' # Do it all in one step
#' cars2 <- etl("mtcars")
#' cars2 %>%
#'   etl_update()
#' src_tbls(cars2)
#'


etl <- function(x, db = NULL, dir = tempdir(), ...) UseMethod("etl")

#' @rdname etl
#' @method etl default
#' @export

etl.default <- function(x, db = NULL, dir = tempdir(), ...) {
  if (!x %in% c("mtcars", "cities")) {
    pkg <- x
    if (!requireNamespace(x, quietly = TRUE)) {
      stop(paste0("Please make sure that the '", x, "' package is installed"))
    }
  } else {
    pkg <- "etl"
  }
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }
  db <- verify_con(db, dir)
  obj <- structure(db, data = NULL, "pkg" = pkg, dir = normalizePath(dir),
                   files = NULL, push = NULL,
                   class = c(paste0("etl_", x), "etl", class(db)))

  # create subdirectories within dir
  raw_dir <- file.path(attr(obj, "dir"), "raw")
  if (!dir.exists(raw_dir)) {
    dir.create(raw_dir)
  }
  load_dir <- file.path(attr(obj, "dir"), "load")
  if (!dir.exists(load_dir)) {
    dir.create(load_dir)
  }
  attr(obj, "raw_dir") <- raw_dir
  attr(obj, "load_dir") <- load_dir
  return(obj)
}

#' @rdname etl
#' @method summary etl
#' @inheritParams base::summary
#' @export
#' @examples
#'
#' # generic summary function provides information about the object
#' cars <- etl("mtcars")
#' summary(cars)

summary.etl <- function(object, ...) {
  cat("files:\n")
  dplyr::bind_rows(summary_dir(attr(object, "raw_dir")),
                   summary_dir(attr(object, "load_dir"))) %>%
    print()
  NextMethod()
}

summary_dir <- function(dir) {
  files <- file.info(list.files(dir, full.names = TRUE))
  # filesize in GB
  data.frame(n = nrow(files),
             size = paste(round(sum(files$size) / 10^9, digits = 3), "GB"),
             path = dir, stringsAsFactors = FALSE)
}

#' @rdname etl
#' @export
#' @inheritParams summary.etl
#' @return For \code{\link{is.etl}}, \code{TRUE} or \code{FALSE},
#' depending on whether \code{x} has class \code{\link{etl}}
#' @examples
#' cars <- etl("mtcars")
#' # returns TRUE
#' is.etl(cars)
#'
#' # returns FALSE
#' is.etl("hello world")

is.etl <- function(object) inherits(object, "etl")

#' @rdname etl
#' @export
#' @inheritParams base::print
#' @importFrom readr parse_number
#' @examples
#' cars <- etl("mtcars") %>%
#'   etl_create()
#' cars

print.etl <- function(x, ...) {
  file_info <- dplyr::bind_rows(
    summary_dir(attr(x, "raw_dir")),
    summary_dir(attr(x, "load_dir"))) %>%
    summarize_(N = ~sum(n), size = ~sum(readr::parse_number(size)))
  cat("dir:  ", file_info$N, " files occupying ",
      file_info$size, " GB\n", sep = "")
  NextMethod()
}
