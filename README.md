[![Travis-CI Build Status](https://travis-ci.org/beanumber/etl.svg?branch=master)](https://travis-ci.org/beanumber/etl)

etl
===

R package to facilitate [ETL](https://en.wikipedia.org/wiki/Extract,_transform,_load) operations

``` r
require(etl)
require(dplyr)
```

``` r
require(RPostgreSQL)
db <- src_postgres(dbname = "mtcars", user = "postgres", host = "localhost")
require(RMySQL)
db <- src_mysql(dbname = "mtcars", user = "r-user", password = "mypass", host = "localhost")
require(RSQLite)
db <- src_sqlite(path = tempfile(), create = TRUE)
```

``` r
cars <- etl("mtcars", db)
str(cars)
```

    ## List of 6
    ##  $ pkg  : chr "mtcars"
    ##  $ con  :Formal class 'SQLiteConnection' [package "RSQLite"] with 5 slots
    ##   .. ..@ Id                 :<externalptr> 
    ##   .. ..@ dbname             : chr "/tmp/RtmpCDI1YI/file77de9780430"
    ##   .. ..@ loadable.extensions: logi TRUE
    ##   .. ..@ flags              : int 6
    ##   .. ..@ vfs                : chr ""
    ##  $ dir  : chr "/tmp/RtmpCDI1YI"
    ##  $ init : NULL
    ##  $ files: NULL
    ##  $ push : NULL
    ##  - attr(*, "class")= chr [1:2] "etl_mtcars" "etl"

Step-by-step
------------

Initialize the database

``` r
require(magrittr)
```

    ## Loading required package: magrittr

``` r
cars %<>%
  etl_init()
str(cars)
```

    ## List of 6
    ##  $ pkg  : chr "mtcars"
    ##  $ con  :Formal class 'SQLiteConnection' [package "RSQLite"] with 5 slots
    ##   .. ..@ Id                 :<externalptr> 
    ##   .. ..@ dbname             : chr "/tmp/RtmpCDI1YI/file77de9780430"
    ##   .. ..@ loadable.extensions: logi TRUE
    ##   .. ..@ flags              : int 6
    ##   .. ..@ vfs                : chr ""
    ##  $ dir  : chr "/tmp/RtmpCDI1YI"
    ##  $ init : logi TRUE
    ##  $ files: NULL
    ##  $ push : NULL
    ##  - attr(*, "class")= chr [1:2] "etl_mtcars" "etl"

Download the raw data

``` r
cars %<>%
  etl_extract()
list.files(cars$dir)
```

    ## [1] "file77de9780430" "mtcars.csv"

Do any data processing

``` r
cars %<>% etl_transform()
```

Push the data to the database

``` r
cars %<>% etl_load()
str(cars)
```

    ## List of 6
    ##  $ pkg  : chr "mtcars"
    ##  $ con  :Formal class 'SQLiteConnection' [package "RSQLite"] with 5 slots
    ##   .. ..@ Id                 :<externalptr> 
    ##   .. ..@ dbname             : chr "/tmp/RtmpCDI1YI/file77de9780430"
    ##   .. ..@ loadable.extensions: logi TRUE
    ##   .. ..@ flags              : int 6
    ##   .. ..@ vfs                : chr ""
    ##  $ dir  : chr "/tmp/RtmpCDI1YI"
    ##  $ init : logi TRUE
    ##  $ files: NULL
    ##  $ push : logi TRUE
    ##  - attr(*, "class")= chr [1:2] "etl_mtcars" "etl"

Do any data cleanup

``` r
cars %<>% etl_cleanup(cars)
```

Streamlined
-----------

OR, do the whole thing in one step!

``` r
cars <- etl("mtcars", db) %>%
  etl_create()
```

You can also update an existing database without re-initializing, but watch out for primary key collisions.

``` r
cars <- etl("mtcars", db) %>%
  etl_update()
```

Do Your Analysis
----------------

Now that your database is populated, you can work with it as a `src` data table just like any other `dplyr` table.

``` r
db %>%
  tbl(from = "mtcars") %>%
  group_by(cyl) %>%
  summarise(N = n(), meanMPG = mean(mpg))
```

    ## Source: sqlite 3.8.6 [/tmp/RtmpCDI1YI/file77de9780430]
    ## From: <derived table> [?? x 3]
    ## 
    ##    cyl  N  meanMPG
    ## 1    4 22 26.66364
    ## 2    6 14 19.74286
    ## 3    8 28 15.10000
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
