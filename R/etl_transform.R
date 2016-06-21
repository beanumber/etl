#' @rdname etl_create
#' @export

etl_transform <- function(obj, ...) UseMethod("etl_transform")

#' @rdname etl_create
#' @method etl_transform default
#' @export

etl_transform.default <- function(obj, ...) {
  # load the data and process it if necessary
  message(paste0("No available methods. Did you write the method etl_transform.", class(obj)[1]), "()?")
  invisible(obj)
}

#' @rdname etl_create
#' @method etl_transform etl_mtcars
#' @importFrom utils read.csv write.csv
#' @export

etl_transform.etl_mtcars <- function(obj, ...) {
  message("Transforming raw data...")
  src <- paste0(attr(obj, "raw_dir"), "/mtcars.csv")
  data <- utils::read.csv(src)
  data <- data %>%
    rename_(makeModel = ~X)
  lcl <- paste0(attr(obj, "load_dir"), "/mtcars.csv")
  utils::write.csv(data, file = lcl, row.names = FALSE)
  invisible(obj)
}


