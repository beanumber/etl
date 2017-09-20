ETL
================

[![Travis-CI Build Status](https://travis-ci.org/beanumber/etl.svg?branch=master)](https://travis-ci.org/beanumber/etl) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/etl)](https://cran.r-project.org/package=etl) [![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/etl)](http://www.r-pkg.org/pkg/etl)

`etl` is an R package to facilitate [Extract - Transform - Load (ETL)](https://en.wikipedia.org/wiki/Extract,_transform,_load) operations for **medium data**. The end result is generally a populated SQL database, but the user interaction takes place solely within R.

`etl` is on CRAN, so you can install it in the usual way, then load it.

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

    ## No database was specified so I created one for you at:

    ## /tmp/RtmpIMUIel/file68b36216d2b2.sqlite3

``` r
class(cars)
```

    ## [1] "etl_mtcars" "etl"        "src_dbi"    "src_sql"    "src"

Connect to a local or remote database
-------------------------------------

`etl` works with a local or remote database to store your data. Every `etl` object extends a `dplyr::src_dbi` object. If, as in the example above, you do not specify a SQL source, a local `RSQLite` database will be created for you. However, you can also specify any source that inherits from `dplyr::src_dbi`.

> Note: If you want to use a database other than a local RSQLite, you must create the `mtcars` database and have permission to write to it first!

``` r
# For PostgreSQL
library(RPostgreSQL)
db <- src_postgres(dbname = "mtcars", user = "postgres", host = "localhost")

# Alternatively, for MySQL
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

    ## Loading 1 file(s) into the database...

Do it all at once
-----------------

To populate the whole database from scratch, use `etl_create`.

``` r
cars %>%
  etl_create()
```

    ## Running SQL script at /home/bbaumer/R/x86_64-pc-linux-gnu-library/3.4/etl/sql/init.sqlite

    ## Extracting raw data...

    ## Transforming raw data...

    ## Loading 1 file(s) into the database...

You can also update an existing database without re-initializing, but watch out for primary key collisions.

``` r
cars %>%
  etl_update()
```

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
    ## # Database: sqlite 3.9.1 [/tmp/RtmpIMUIel/file68b36216d2b2.sqlite3]
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

Please see the "[Extending etl](https://github.com/beanumber/etl/blob/master/vignettes/extending_etl.Rmd)" vignette for more information.

Use other ETL packages
----------------------

-   [macleish](https://github.com/beanumber/etl) [![Travis-CI Build Status](https://travis-ci.org/beanumber/macleish.svg?branch=master)](https://travis-ci.org/beanumber/macleish) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/macleish)](https://cran.r-project.org/package=macleish) : Weather and spatial data from the MacLeish Field Station in Whately, MA.
-   [airlines](https://github.com/beanumber/airlines) [![Travis-CI Build Status](https://travis-ci.org/beanumber/airlines.svg?branch=master)](https://travis-ci.org/beanumber/airlines) : On-time flight arrival data from the Bureau of Transportation Statistics
-   [citibike](https://github.com/beanumber/citibike) [![Travis-CI Build Status](https://travis-ci.org/beanumber/citibike.svg?branch=master)](https://travis-ci.org/beanumber/citibike) : Municipal bike-sharing system in New York City
-   [nyc311](https://github.com/beanumber/nyc311) [![Travis-CI Build Status](https://travis-ci.org/beanumber/nyc311.svg?branch=master)](https://travis-ci.org/beanumber/nyc311) : Phone calls to New York City's feedback hotline
-   [fec](https://github.com/beanumber/fec) [![Travis-CI Build Status](https://travis-ci.org/beanumber/fec.svg?branch=master)](https://travis-ci.org/beanumber/fec) : Campaign contribution data from the Federal Election Commission
-   [imdb](https://github.com/beanumber/imdb) [![Travis-CI Build Status](https://travis-ci.org/beanumber/imdb.svg?branch=master)](https://travis-ci.org/beanumber/imdb) : Mirror of the Internet Movie Database

Cite
----

Please see [the full manuscript](https://arxiv.org/abs/1708.07073) for additional details.

``` r
citation("etl")
```

    ## 
    ## To cite package 'etl' in publications use:
    ## 
    ##   Ben Baumer (2017). etl: Extract-Transform-Load Framework for
    ##   Medium Data. R package version 0.3.6.9000.
    ##   http://github.com/beanumber/etl
    ## 
    ## A BibTeX entry for LaTeX users is
    ## 
    ##   @Manual{,
    ##     title = {etl: Extract-Transform-Load Framework for Medium Data},
    ##     author = {Ben Baumer},
    ##     year = {2017},
    ##     note = {R package version 0.3.6.9000},
    ##     url = {http://github.com/beanumber/etl},
    ##   }
