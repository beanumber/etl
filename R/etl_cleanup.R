#' @rdname etl_create
#' @export

etl_cleanup <- function(obj, ...) UseMethod("etl_cleanup")

#' @rdname etl_create
#' @method etl_cleanup default
#' @export

etl_cleanup.default <- function(obj, ...) {
  # delete files
  # run VACCUUM ANALYZE, etc.
  message(paste0("No available methods. Did you write the method etl_cleanup.", class(obj)[1]), "()?")
  invisible(obj)
}

#' @rdname etl_create
#' @method etl_cleanup etl_mtcars
#' @param delete_raw should files be deleted from the \code{raw_dir}?
#' @param delete_load should files be deleted from the \code{load_dir}?
#' @param pattern regular expression matching file names to be deleted. By default,
#' this matches filenames ending in \code{.csv} and \code{.zip}.
#' @export

etl_cleanup.etl_mtcars <- function(obj, delete_raw = FALSE, delete_load = FALSE, pattern = "\\.(csv|zip)$", ...) {
  # delete files
  raw <- attr(obj, "raw_dir")
  load <- attr(obj, "load_dir")
  if (delete_raw) {
    message(paste0("Deleting files from ", raw))
    raw_files <- list.files(raw)
    unlink(paste0(raw, "/", raw_files[grepl(pattern, raw_files, ...)]))
  }
  if (delete_load) {
    message(paste0("Deleting files from ", load))
    load_files <- list.files(load)
    unlink(paste0(load, "/", load_files[grepl(pattern, load_files, ...)]))
  }
  # run VACCUUM ANALYZE, etc.
  invisible(obj)
}
