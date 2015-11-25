---
output:
  md_document:
    variant: markdown_github
---

[![Travis-CI Build Status](https://travis-ci.org/beanumber/etl.svg?branch=master)](https://travis-ci.org/beanumber/etl)

# etl
`etl` is an R package to facilitate [Extract - Transform - Load (ETL)](https://en.wikipedia.org/wiki/Extract,_transform,_load) operations. The end result is a populated SQL database, but the user interaction takes place solely within R.

To install, use the `devtools` package, and then load it. 


```r
devtools::install_github("beanumber/etl")
```


```r
require(etl)
```

In order to populate the SQL database, you need to connect to it. `etl` accepts connections from either `dplyr` or `DBI` -- here we demonstrate the `dplyr` interface. **Note:** you must create the `mtcars` database and have permission to write to it!


```r
require(dplyr)
# require(RPostgreSQL)
# db <- src_postgres(dbname = "mtcars", user = "postgres", host = "localhost")
# require(RMySQL)
# db <- src_mysql(dbname = "mtcars", user = "r-user", password = "mypass", host = "localhost")
require(RSQLite)
db <- src_sqlite(path = tempfile(), create = TRUE)
```

Instantiate an `etl` object using a string that determines the class of the resulting object, and the package that provides access to that data. The trivial `mtcars` database is built into `etl`. 


```r
cars <- etl("mtcars", db)
```

```
## Error in etl("mtcars", db): unused argument (db)
```

```r
class(cars)
```

```
## [1] "data.frame"
```

# Populate the database

To populate the whole database from scratch, use `etl_create`. 


```r
cars <- etl("mtcars", db) %>%
  etl_create()
```

```
## Error in etl("mtcars", db): unused argument (db)
```

You can also update an existing database without re-initializing, but watch out for primary key collisions.


```r
cars <- etl("mtcars", db) %>%
  etl_update()
```

## Step-by-step

Under the hood, there are five functions that `etl` chains together:


```r
getS3method("etl_create", "default")
```

```
## Error in getS3method("etl_create", "default"): no function 'etl_create' could be found
```

```r
getS3method("etl_update", "default")
```

```
## Error in getS3method("etl_update", "default"): no function 'etl_update' could be found
```

## Do Your Analysis

Now that your database is populated, you can work with it as a `src` data table just like any other `dplyr` table. 

```r
db %>%
  tbl(from = "mtcars") %>%
  group_by(cyl) %>%
  summarise(N = n(), meanMPG = mean(mpg))
```

```
## Error: Table mtcars not found in database /var/folders/wc/zv89d1fx5nxdljsysq40m6vr0000gn/T//RtmpZl4na3/file7c6a7c0c86a
```

## Create your own ETL packages

Suppose you want to create your own ETL package called `pkgname`. All you have to do is write a package that requires `etl`, and then you have to write **two S3 methods**:


```r
etl_extract.etl_pkgname()
etl_load.etl_pkgname()
```

You may also wish to write


```r
etl_init.etl_pkgname()
etl_transform.etl_pkgname()
etl_cleanup.etl_pkgname()
```

All of these functions must take and return an object of class `etl_pkgname` that inherits from `etl`. Please see the [`airlines`](https://github.com/beanumber/airlines) package for an example. 

## Use other ETL packages

Packages that use the `etl` framework:


```r
tools::dependsOnPkgs("etl")
```

```
## character(0)
```
