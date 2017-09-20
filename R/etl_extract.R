#' @rdname etl_create
#' @export

etl_extract <- function(obj, ...) UseMethod("etl_extract")

#' @rdname etl_create
#' @method etl_extract default
#' @importFrom readr write_csv
#' @importFrom utils data
#' @export

etl_extract.default <- function(obj, ...) {
  pkg <- attr(obj, "pkg")
  data_sets <- utils::data(package = pkg)$results %>%
    dplyr::as_data_frame() %>%
    dplyr::mutate_(data_path = ~paste0(Package, "::", Item),
                   file_path = ~file.path(attr(obj, "raw_dir"),
                                          paste0(Item, ".csv")))

  # load the data.frames into a list
  data_list <- lapply(data_sets$data_path, get_data)
  # check to see which ones are data.frames
  is_df <- lapply(data_list, is.data.frame) %>%
    unlist()

  # check to see if list-columns exist
  is_rectangular <- sapply(data_list,
                           function(x) { unlist(!any(sapply(x, class) == "list")); })

  good <- is_df + is_rectangular == 2
  # write the data.frames as CSVs
  mapply(FUN = readr::write_csv, data_list[good], data_sets$file_path[good])

  invisible(obj)
}

#' @importFrom rlang parse_expr

get_data <- function(x) {
  # https://stackoverflow.com/questions/30951204/load-dataset-from-r-package-using-data-assign-it-directly-to-a-variable
  eval(rlang::parse_expr(x))
}


#' @rdname etl_create
#' @method etl_extract etl_mtcars
#' @importFrom utils write.csv
#' @export

etl_extract.etl_mtcars <- function(obj, ...) {
  message("Extracting raw data...")
  raw_filename <- file.path(attr(obj, "raw_dir"), "mtcars.csv")
  utils::write.csv(datasets::mtcars, file = raw_filename)
  invisible(obj)
}

#' @rdname etl_create
#' @method etl_extract etl_cities
#' @export

etl_extract.etl_cities <- function(obj, ...) {
  src <- c("https://en.wikipedia.org/wiki/List_of_largest_cities",
           "https://en.wikipedia.org/wiki/List_of_United_States_cities_by_population")
  smart_download(obj, src, new_filenames = paste0(basename(src), ".html"), ...)
  invisible(obj)
}


#' Download only those files that don't already exist
#' @param obj an \code{\link{etl}} object
#' @param src a character vector of URLs that you want to download
#' @param new_filenames an optional character vector of filenames for the new
#'  (local) files. Defaults to having the same filenames as those in \code{src}.
#' @param clobber do you want to clobber any existing files?
#' @param ... arguments passed to \code{\link[downloader]{download}}
#' @details Downloads only those files in \code{src} that are not already present in
#' the directory specified by the \code{raw_dir} attribute of \code{obj}.
#' @author idiom courtesy of Hadley Wickham
#' @importFrom downloader download
#' @export
#'
#' @examples
#' cars <- etl("mtcars")
#' urls <- c("https://raw.githubusercontent.com/beanumber/etl/master/etl.Rproj",
#' "https://www.reddit.com/robots.txt")
#' smart_download(cars, src = urls)
#' # won't download again if the files are already there
#' smart_download(cars, src = urls)
#' # use clobber to overwrite
#' smart_download(cars, src = urls, clobber = TRUE)
smart_download <- function(obj, src, new_filenames = basename(src), clobber = FALSE, ...) {
  if (length(src) != length(new_filenames)) {
    stop("src and new_filenames must be of the same length")
  }
  lcl <- file.path(attr(obj, "raw_dir"), new_filenames)
  if (!clobber) {
    missing <- !file.exists(lcl)
  } else {
    missing <- new_filenames == new_filenames
  }
  message(paste("Downloading", sum(missing), "new files. ",
                sum(!missing), "untouched."))
  mapply(downloader::download, src[missing], lcl[missing], ... = ...)
}


