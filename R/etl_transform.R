#' @rdname etl_create
#' @export

etl_transform <- function(obj, ...) UseMethod("etl_transform")

#' @rdname etl_create
#' @export

etl_transform.default <- function(obj, ...) {
  # load the data and process it if necessary
  src <- list.files(attr(obj, "raw_dir"), "\\.csv", full.names = TRUE)
  lcl <- file.path(attr(obj, "load_dir"), basename(src))
  file.copy(from = src, to = lcl)
  invisible(obj)
}

#' @rdname etl_create
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

  world_cities <- get_longest_table(tables[[1]]) %>%
    janitor::clean_names() %>%
    filter(city != "City") %>%
    mutate(
      city_pop = readr::parse_number(population),
      metro_pop = readr::parse_number(population_2),
      urban_pop = readr::parse_number(population_3),
      # strip commas to avoid breaking SQLite import
      Nation = gsub(",", "_", nation)
    ) %>%
    select(city, nation, contains("_pop"))

  us_cities <- get_longest_table(tables[[2]]) %>%
    janitor::clean_names() %>%
    mutate(
      city = gsub("\\[[a-z0-9]+\\]", "", city),
      pop_2018 = readr::parse_number(`x2018estimate`),
      pop_2010 = readr::parse_number(`x2010census`),
      pop_density_2016 = readr::parse_number(`x2016_population_density`),
      pop_density_2010 = readr::parse_number(`x2016_population_density_2`),
      # strip commas to avoid breaking SQLite import
      location = gsub(",", "_", location)
    ) %>%
    rename(state = `state_c`) %>%
    select(city, state, pop_2018, pop_2010,
           pop_density_2016, pop_density_2010, location)

  lcl <- file.path(attr(obj, "load_dir"), c("world_cities.csv", "us_cities.csv"))

  mapply(readr::write_csv, list(world_cities, us_cities), lcl)
  invisible(obj)
}

globalVariables(
  c("x2010census", "x2018estimate", "population" , "Var1", "Var2", "X",
    "city", "file_date", "month_begin", "nation", "pop_2010", "pop_2018",
    "pop_density_2010", "pop_density_2016", "population_2", "population_3",
    "size", "state", "state_c", "x2016_population_density",
    "x2016_population_density_2")
)
