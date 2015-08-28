[![Travis-CI Build Status](https://travis-ci.org/beanumber/etl.svg?branch=master)](https://travis-ci.org/beanumber/etl)

etl
===

`etl` is an R package to facilitate [Extract - Transform - Load (ETL)](https://en.wikipedia.org/wiki/Extract,_transform,_load) operations. The end result is a populated SQL database, but the user interaction takes place solely within R.

To install, use the `devtools` package, and then load it.

``` r
devtools::install_github("beanumber/etl")
```

``` r
require(etl)
```

In order to populate the SQL database, you need to connect to it. `etl` accepts connections from either `dplyr` or `DBI` -- here we demonstrate the `dplyr` interface. **Note:** you must create the `mtcars` database and have permission to write to it!

``` r
require(dplyr)
# require(RPostgreSQL)
# db <- src_postgres(dbname = "mtcars", user = "postgres", host = "localhost")
# require(RMySQL)
# db <- src_mysql(dbname = "mtcars", user = "r-user", password = "mypass", host = "localhost")
require(RSQLite)
db <- src_sqlite(path = tempfile(), create = TRUE)
```

Instantiate an `etl` object using a string that determines the class of the resulting object, and the package that provides access to that data. The trivial `mtcars` database is built into `etl`.

``` r
cars <- etl("mtcars", db)
class(cars)
```

    ## [1] "etl_mtcars" "etl"

Populate the database
=====================

To populate the whole database from scratch, use `etl_create`.

``` r
cars <- etl("mtcars", db) %>%
  etl_create()
```

You can also update an existing database without re-initializing, but watch out for primary key collisions.

``` r
cars <- etl("mtcars", db) %>%
  etl_update()
```

Step-by-step
------------

Under the hood, there are five functions that `etl` chains together:

``` r
getS3method("etl_create", "default")
```

    ## function(obj, ...) {
    ##   if (is.null(obj$init)) {
    ##     obj <- etl_init(obj, ...)
    ##   }
    ##   etl_update(obj, ...)
    ## }
    ## <environment: namespace:etl>

``` r
getS3method("etl_update", "default")
```

    ## function(obj, ...) {
    ##   obj %<>%
    ##     etl_extract(...) %>%
    ##     etl_transform(...) %>%
    ##     etl_load(...)
    ##   if (!is.null(obj$push)) {
    ##     etl_cleanup(obj, ...)
    ##   } else {
    ##     warning("Unable to push data to the database?")
    ##   }
    ##   return(obj)
    ## }
    ## <environment: namespace:etl>

Do Your Analysis
----------------

Now that your database is populated, you can work with it as a `src` data table just like any other `dplyr` table.

``` r
db %>%
  tbl(from = "mtcars") %>%
  group_by(cyl) %>%
  summarise(N = n(), meanMPG = mean(mpg))
```

    ## Source: sqlite 3.8.6 [/tmp/RtmpMQdCVD/file7dcc5093e34a]
    ## From: <derived table> [?? x 3]
    ## 
    ##    cyl  N  meanMPG
    ## 1    4 11 26.66364
    ## 2    6  7 19.74286
    ## 3    8 14 15.10000
    ## .. ... ..      ...

Create your own ETL packages
----------------------------

Suppose you want to create your own ETL package called `pkgname`. All you have to do is write a package that requires `etl`, and then you have to write **two S3 methods**:

``` r
etl_extract.etl_pkgname()
etl_load.etl_pkgname()
```

You may also wish to write

``` r
etl_init.etl_pkgname()
etl_transform.etl_pkgname()
etl_cleanup.etl_pkgname()
```

All of these functions must take and return an object of class `etl_pkgname` that inherits from `etl`. Please see the [`airlines`](https://github.com/beanumber/airlines) package for an example.

Use other ETL packages
----------------------

Packages that use the `etl` framework:

``` r
tools::dependsOnPkgs("etl")
```

    ## [1] "airlines"
