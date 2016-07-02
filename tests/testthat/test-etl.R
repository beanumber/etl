context("etl")

## TODO: Rename context
## TODO: Add more tests

test_that("sqlite works", {
  cars_sqlite <- etl("mtcars")
  expect_s3_class(cars_sqlite, "etl_mtcars")
  expect_s3_class(cars_sqlite, "etl")
  expect_s3_class(cars_sqlite, "src_sqlite")
  expect_s3_class(cars_sqlite, "src_sql")
  expect_true(file.exists(find_schema(cars_sqlite)))
  expect_message(find_schema(cars, "my_crazy_schema", "etl"))
  expect_output(summary(cars_sqlite), "/tmp")
})

test_that("dplyr works", {
  expect_message(cars <- etl("mtcars") %>%
    etl_create(), regexp = "success")
  expect_gt(length(src_tbls(cars)), 0)
  tbl_cars <- cars %>%
     tbl("mtcars")
  expect_s3_class(tbl_cars, "tbl_sqlite")
  expect_s3_class(tbl_cars, "tbl_sql")
  res <- tbl_cars %>%
    collect()
  expect_equal(nrow(res), nrow(mtcars))
  # double up the data
  expect_message(
    cars %>%
      etl_update(), regexp = "success")
  res2 <- tbl_cars %>%
    collect()
  expect_equal(nrow(res2), 2 * nrow(mtcars))
})


# test_that("mysql works", {
#   db <- src_mysql(default.file = "~/.my.cnf", dbname = "mtcars",
#                   user = NULL, password = NULL)
#   cars <- etl("mtcars", db = db)
#   class(cars)
#   expect_true(file.exists(find_schema(cars, "mtcars", "etl")))
#   cars %>% etl_create()
# })

test_that("MonetDBLite works", {
  if (require(MonetDBLite)) {
    db <- MonetDBLite::src_monetdblite()
    cars_monet <- etl("mtcars", db = db)
    expect_message(
      cars_monet %>%
        etl_create()
    )
    tbl_cars <- cars_monet %>%
      tbl("mtcars")
    expect_equal(nrow(tbl_cars %>% collect()), 32)
    expect_s3_class(cars_monet, "src_monetdb")
    expect_s3_class(tbl_cars, "tbl_monetdb")
  }
})

test_that("valid_year_month works", {
  expect_equal(nrow(valid_year_month(years = 1999:2001, months = c(1:3, 7))), 12)
})

test_that("extract_date_from_filename works", {
  test <- expand.grid(year = 1999:2001, month = c(1:6, 9)) %>%
    mutate(filename = paste0("myfile_", year, "_", month, ".ext"))
  expect_is(extract_date_from_filename(test$filename, pattern = "myfile_%Y_%m.ext"), "Date")
  expect_null(extract_date_from_filename(list.files("/cdrom"), pattern = "*"))
})
