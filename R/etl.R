#' Initialize an \code{etl} object
#'
#' @description Initialize an \code{etl} object
#'
#' @param x the name of the \code{etl} package that you wish to populate with data.
#' This determines the class of the resulting \code{\link{etl}} object, which
#' determines method dispatch of \code{etl_*()} functions. There is no default,
#' but you can use \code{mtcars} as an test example.
#' @param db a database connection that inherits from \code{\link[dplyr]{src_sql}}. It is
#' NULL by default, which results in a \code{\link[dplyr]{src_sqlite}} connection
#' being created in \code{dir}.
#' @param dir a directory to store the raw and processed data files
#' @param ... arguments passed to methods (currently ignored)
#' @details A constructor function that instantiates an \code{\link{etl}} object.
#' An \code{\link{etl}} object extends a \code{\link[dplyr]{src_sql}} object.
#' It also has attributes for:
#' \describe{
#'  \item{pkg}{the name of the \code{\link{etl}} package corresponding to the data source}
#'  \item{dir}{the directory where the raw and processed data are stored}
#'  \item{raw_dir}{the directory where the raw data files are stored}
#'  \item{load_dir}{the directory where the processed data files are stored}
#'  }
#' Just like any \code{\link[dplyr]{src_sql}} object, an \code{\link{etl}} object
#' is a data source backed by an SQL database. However, an \code{\link{etl}} object
#' has additional functionality based on the presumption that the SQL database
#' will be populated from data files stored on the local hard disk. The ETL functions
#' documented in \code{\link{etl_create}} provide the necessary funcitonality
#' for \strong{extract}ing data from the Internet to \code{raw_dir},
#' \strong{transform}ing those data
#' and placing the cleaned up data (usually in CSV format) into \code{load_dir},
#' and finally \strong{load}ing the clean data into the SQL database.
#' @return an object of class \code{etl_x} and \code{\link{etl}} that inherits
#' from \code{\link[dplyr]{src_sql}}
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
  if (x != "mtcars") {
    if (!requireNamespace(x)) {
      stop(paste0("Please make sure that the '", x, "' package is installed"))
    }
  }
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }
  db <- verify_con(db, dir)
  obj <- structure(db, data = NULL, "pkg" = x, dir = normalizePath(dir),
              files = NULL, push = NULL, class = c(paste0("etl_", x), "etl", class(db)))

  # create subdirectories within dir
  raw_dir <- paste0(attr(obj, "dir"), "/raw")
  if (!dir.exists(raw_dir)) {
    dir.create(raw_dir)
  }
  load_dir <- paste0(attr(obj, "dir"), "/load")
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


