#' @rdname etl_create
#' @export

etl_extract <- function(obj, ...) UseMethod("etl_extract")

#' @rdname etl_create
#' @method etl_extract default
#' @export

etl_extract.default <- function(obj, ...) {
  # download the data from the Internet
  warning(paste0("No available methods. Did you write the method etl_extract.",
                 class(obj)[1]), "()?")
  invisible(obj)
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


