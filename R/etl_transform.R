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

#' @rdname etl_create
#' @method etl_transform etl_cities
#' @importFrom rvest html_table
#' @importFrom tibble set_tidy_names
#' @importFrom xml2 read_html
#' @importFrom readr parse_number
#' @export

etl_transform.etl_cities <- function(obj, ...) {
  src <- list.files(attr(obj, "raw_dir"), pattern = "\\.html", full.names = TRUE)
  pages <- lapply(src, xml2::read_html)
  tables <- lapply(pages, rvest::html_table, fill = TRUE)

  get_longest_table <- function(x) {
    nrows <- lapply(x, nrow) %>%
      unlist()
    x[[which.max(nrows)]]
  }

  suppressWarnings(
  world_cities <- get_longest_table(tables[[1]]) %>%
    tibble::set_tidy_names() %>%
    filter_(~City != "") %>%
    mutate_(
      city_pop = ~readr::parse_number(`Population..4`),
      metro_pop = ~readr::parse_number(`Population..5`),
      urban_pop = ~readr::parse_number(`Population..6`),
      # strip commas to avoid breaking SQLite import
      Country = ~gsub(",", "_", `Country`)
    ) %>%
    select_(~City, ~Country, ~city_pop, ~metro_pop, ~urban_pop)
  )
  us_cities <- get_longest_table(tables[[2]]) %>%
    tibble::set_tidy_names() %>%
    mutate_(
      City = ~gsub("\\[[0-9]+\\]", "", City),
      pop_2016 = ~readr::parse_number(`2016\nestimate`),
      pop_2010 = ~readr::parse_number(`2010\nCensus`),
      pop_density_2016 = ~readr::parse_number(`2016 population density..9`),
      pop_density_2010 = ~readr::parse_number(`2016 population density..10`),
      # strip commas to avoid breaking SQLite import
      Location = ~gsub(",", "_", Location)
    ) %>%
    rename_(State = ~`State[5]`) %>%
    select_(~City, ~State, ~pop_2016, ~pop_2010,
            ~pop_density_2016, ~pop_density_2010, ~Location)

  lcl <- file.path(attr(obj, "load_dir"), c("world_cities.csv", "us_cities.csv"))

  mapply(utils::write.csv, list(world_cities, us_cities), lcl, row.names = FALSE)
  invisible(obj)
}


