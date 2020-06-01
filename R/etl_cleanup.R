#' @rdname etl_create
#' @export

etl_cleanup <- function(obj, ...) UseMethod("etl_cleanup")

#' @rdname etl_create
#' @param delete_raw should files be deleted from the \code{raw_dir}?
#' @param delete_load should files be deleted from the \code{load_dir}?
#' @param pattern regular expression matching file names to be deleted. By default,
#' this matches filenames ending in \code{.csv} and \code{.zip}.
#' @export

etl_cleanup.default <- function(obj,
                                delete_raw = FALSE,
                                delete_load = FALSE,
                                pattern = "\\.(csv|zip)$", ...) {
  # delete files
  raw <- attr(obj, "raw_dir")
  load <- attr(obj, "load_dir")
  if (delete_raw) {
    message(paste0("Deleting files from ", raw))
    raw_files <- list.files(raw)
    unlink(file.path(raw, raw_files[grepl(pattern, raw_files, ...)]))
  }
  if (delete_load) {
    message(paste0("Deleting files from ", load))
    load_files <- list.files(load)
    unlink(file.path(load, load_files[grepl(pattern, load_files, ...)]))
  }
  # run VACCUUM ANALYZE, etc.
  invisible(obj)
}
