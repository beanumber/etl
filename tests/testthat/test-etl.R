context("etl")

## TODO: Rename context
## TODO: Add more tests

test_that("instantiation works", {
  cars <- etl("mtcars")
  expect_s3_class(cars, "etl_mtcars")
  expect_s3_class(cars, "etl")
  expect_s3_class(cars, "src_sql")
})

test_that("dplyr works", {
  cars <- etl("mtcars") %>%
    etl_create()
  expect_gt(length(src_tbls(cars)), 0)
  tbl_cars <- cars %>%
     tbl("mtcars")
  expect_s3_class(tbl_cars, "tbl_sqlite")
  expect_s3_class(tbl_cars, "tbl_sql")
  res <- tbl_cars %>%
    collect()
  expect_equal(nrow(res), nrow(mtcars))
  # double up the data
  cars %>%
    etl_update()
  res2 <- tbl_cars %>%
    collect()
  expect_equal(nrow(res2), 2 * nrow(mtcars))
})
