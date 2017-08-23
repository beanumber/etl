#' @rdname etl_create
#' @export

etl_transform <- function(obj, ...) UseMethod("etl_transform")

#' @rdname etl_create
#' @method etl_transform default
#' @export

etl_transform.default <- function(obj, ...) {
  # load the data and process it if necessary
  src <- list.files(attr(obj, "raw_dir"), "\\.csv", full.names = TRUE)
  lcl <- file.path(attr(obj, "load_dir"), basename(src))
  file.copy(from = src, to = lcl)
  invisible(obj)
}

#' @rdname etl_create
#' @method etl_transform etl_mtcars
#' @importFrom utils read.csv write.csv
#' @export

etl_transform.etl_mtcars <- function(obj, ...) {
  message("Transforming raw data...")
  src <- file.path(attr(obj, "raw_dir"), "mtcars.csv")
  data <- utils::read.csv(src)
  data <- data %>%
    rename_(makeModel = ~X)
  lcl <- file.path(attr(obj, "load_dir"), "mtcars.csv")
  utils::write.csv(data, file = lcl, row.names = FALSE)
  invisible(obj)
}


