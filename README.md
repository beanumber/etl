[![Travis-CI Build Status](https://travis-ci.org/beanumber/etl.svg?branch=master)](https://travis-ci.org/beanumber/etl)

etl
===

`etl` is an R package to facilitate [Extract - Transform - Load (ETL)](https://en.wikipedia.org/wiki/Extract,_transform,_load) operations for **medium data**. The end result is generally a populated SQL database, but the user interaction takes place solely within R.

To install, use the `devtools` package, and then load it.

``` r
devtools::install_github("beanumber/etl")
```

``` r
require(etl)
```

Instantiate an `etl` object using a string that determines the class of the resulting object, and the package that provides access to that data. The trivial `mtcars` database is built into `etl`.

``` r
cars <- etl("mtcars")
```

    ## Not a valid src. Creating a src_sqlite for you at /tmp/RtmpJTbjbO/file508d47c47c5.sqlite3

``` r
class(cars)
```

    ## [1] "etl_mtcars" "etl"        "src_sqlite" "src_sql"    "src"

Connect to a local or remote database
-------------------------------------

`etl` works with a local or remote database to store your data. Every `etl` object extends a `dplyr::src_sql` object. If, as in the example above, you do not specify a SQL source, a local `RSQLite` database will be created for you. However, you can also specify any source that inherits from `dplyr::src_sql`.

> Note: If you want to use a database other than a local RSQLite, you must create the `mtcars` database and have permission to write to it first!

``` r
require(RPostgreSQL)
db <- src_postgres(dbname = "mtcars", user = "postgres", host = "localhost")
require(RMySQL)
db <- src_mysql(dbname = "mtcars", user = "r-user", password = "mypass", host = "localhost")
cars <- etl("mtcars", db)
```

At the heart of `etl` are three functions: `etl_extract()`, `etl_transform()`, and `etl_load()`.

Download data from an online source
-----------------------------------

The first step is to acquire data from an online source.

``` r
cars %>%
  etl_extract()
```

    ## Extracting raw data...

    ## src:  sqlite 3.8.6 [/tmp/RtmpJTbjbO/file508d47c47c5.sqlite3]
    ## tbls:

This creates a local store of raw data.

Transform that data from its raw form to data.frame(s)
------------------------------------------------------

``` r
cars %>%
  etl_transform()
```

    ## Transforming raw data...

    ## src:  sqlite 3.8.6 [/tmp/RtmpJTbjbO/file508d47c47c5.sqlite3]
    ## tbls:

Populate the database
---------------------

``` r
cars %>%
  etl_load()
```

    ## Data was successfully written to database.
    ## mtcars

    ## src:  sqlite 3.8.6 [/tmp/RtmpJTbjbO/file508d47c47c5.sqlite3]
    ## tbls: mtcars

Do it all at once
-----------------

To populate the whole database from scratch, use `etl_create`.

``` r
cars %>%
  etl_create()
```

    ## Extracting raw data...
    ## Transforming raw data...

    ## Warning in sqliteFetch(res, n = n): resultSet does not correspond to a
    ## SELECT statement

    ## Warning in sqliteFetch(res, n = n): resultSet does not correspond to a
    ## SELECT statement

    ## list()list()
    ## Data was successfully written to database.
    ## mtcars

    ## src:  sqlite 3.8.6 [/tmp/RtmpJTbjbO/file508d47c47c5.sqlite3]
    ## tbls: mtcars

You can also update an existing database without re-initializing, but watch out for primary key collisions.

``` r
cars %>%
  etl_update()
```

Step-by-step
------------

Under the hood, there are five functions that `etl` chains together:

``` r
getS3method("etl_create", "default")
```

    ## function(obj, ...) {
    ##   etl_update(obj, schema = TRUE, ...)
    ## }
    ## <environment: namespace:etl>

``` r
getS3method("etl_update", "default")
```

    ## function(obj, ...) {
    ##   obj <- obj %>%
    ##     etl_extract(...) %>%
    ##     etl_transform(...) %>%
    ##     etl_load(...) %>%
    ##     etl_cleanup(...)
    ##   return(obj)
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

    ## Source: sqlite 3.8.6 [/tmp/RtmpJTbjbO/file508d47c47c5.sqlite3]
    ## From: <derived table> [?? x 3]
    ## 
    ##      cyl     N mean_mpg
    ##    (int) (int)    (dbl)
    ## 1      4    11 26.66364
    ## 2      6     7 19.74286
    ## 3      8    14 15.10000
    ## ..   ...   ...      ...

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

All of these functions must take and return an object of class `etl_pkgname` that inherits from `etl`. Please see the [`airlines`](https://github.com/beanumber/airlines) package for an example.

Use other ETL packages
----------------------

Packages that use the `etl` framework:

``` r
tools::dependsOnPkgs("etl")
```

    ## [1] "airlines"
