ETL
================

[![Travis-CI Build Status](https://travis-ci.org/beanumber/etl.svg?branch=master)](https://travis-ci.org/beanumber/etl) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/etl)](https://cran.r-project.org/package=etl) [![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/etl)](http://www.r-pkg.org/pkg/etl)

`etl` is an R package to facilitate [Extract - Transform - Load (ETL)](https://en.wikipedia.org/wiki/Extract,_transform,_load) operations for **medium data**. The end result is generally a populated SQL database, but the user interaction takes place solely within R.

`etl` is now on CRAN, so you can install it in the usual way, then load it.

``` r
install.packages("etl")
```

``` r
library(etl)
```

Instantiate an `etl` object using a string that determines the class of the resulting object, and the package that provides access to that data. The trivial `mtcars` database is built into `etl`.

``` r
cars <- etl("mtcars")
```

    ## Not a valid src. Creating a src_sqlite for you at:

    ## /tmp/Rtmp9uullQ/file735a32cac3de.sqlite3

``` r
class(cars)
```

    ## [1] "etl_mtcars" "etl"        "src_dbi"    "src_sql"    "src"

Connect to a local or remote database
-------------------------------------

`etl` works with a local or remote database to store your data. Every `etl` object extends a `dplyr::src_dbi` object. If, as in the example above, you do not specify a SQL source, a local `RSQLite` database will be created for you. However, you can also specify any source that inherits from `dplyr::src_dbi`.

> Note: If you want to use a database other than a local RSQLite, you must create the `mtcars` database and have permission to write to it first!

``` r
library(RPostgreSQL)
db <- src_postgres(dbname = "mtcars", user = "postgres", host = "localhost")
library(RMySQL)
db <- src_mysql(dbname = "mtcars", user = "r-user", password = "mypass", host = "localhost")
cars <- etl("mtcars", db)
```

At the heart of `etl` are three functions: `etl_extract()`, `etl_transform()`, and `etl_load()`.

Extract
-------

The first step is to acquire data from an online source.

``` r
cars %>%
  etl_extract()
```

    ## Extracting raw data...

This creates a local store of raw data.

Transform
---------

These data may need to be transformed from their raw form to files suitable for importing into SQL (usually CSVs).

``` r
cars %>%
  etl_transform()
```

    ## Transforming raw data...

Load
----

Populate the SQL database with the transformed data.

``` r
cars %>%
  etl_load()
```

    ## Uploading 1 file(s) to the database...

Do it all at once
-----------------

To populate the whole database from scratch, use `etl_create`.

``` r
cars %>%
  etl_create()
```

    ## Loading SQL script at /home/bbaumer/R/x86_64-pc-linux-gnu-library/3.2/etl/sql/init.sqlite

    ## Extracting raw data...

    ## Transforming raw data...

    ## Uploading 1 file(s) to the database...

You can also update an existing database without re-initializing, but watch out for primary key collisions.

``` r
cars %>%
  etl_update()
```

Step-by-step
------------

Under the hood, there are four functions that `etl_update` chains together:

``` r
getS3method("etl_update", "default")
```

    ## function(obj, ...) {
    ##   obj <- obj %>%
    ##     etl_extract(...) %>%
    ##     etl_transform(...) %>%
    ##     etl_load(...)
    ##   invisible(obj)
    ## }
    ## <environment: namespace:etl>

`etl_create` is simply a call to `etl_update` that forces the SQL database to be written from scratch.

``` r
getS3method("etl_create", "default")
```

    ## function(obj, ...) {
    ##   obj <- obj %>%
    ##     etl_init(...) %>%
    ##     etl_update(...) %>%
    ##     etl_cleanup(...)
    ##   invisible(obj)
    ## }
    ## <environment: namespace:etl>

Do Your Analysis
----------------

Now that your database is populated, you can work with it as a `src` data table just like any other `dplyr` source.

``` r
cars %>%
  tbl("mtcars") %>%
  group_by(cyl) %>%
  summarise(N = n(), mean_mpg = mean(mpg))
```

    ## # Source:   lazy query [?? x 3]
    ## # Database: sqlite 3.19.3 [/tmp/Rtmp9uullQ/file735a32cac3de.sqlite3]
    ##     cyl     N mean_mpg
    ##   <int> <int>    <dbl>
    ## 1     4    11 26.66364
    ## 2     6     7 19.74286
    ## 3     8    14 15.10000

Create your own ETL packages
----------------------------

Suppose you want to create your own ETL package called `pkgname`. All you have to do is write a package that requires `etl`, and then you have to write **two S3 methods**:

``` r
etl_extract.etl_pkgname()
etl_load.etl_pkgname()
```

You may also wish to write

``` r
etl_transform.etl_pkgname()
etl_cleanup.etl_pkgname()
```

All of these functions must take and return an object of class `etl_pkgname` that inherits from `etl`. Please see the packages listed below for examples.

Use other ETL packages
----------------------

Packages that use the `etl` framework:

``` r
tools::dependsOnPkgs("etl")
```

    ## [1] "airlines" "imdb"     "macleish" "nyc311"   "nyctaxi"
