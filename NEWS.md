# etl 0.3.4

* Added `src_mysql_cnf` as shorthand for connecting to MySQL
* Fixed CRAN failures on Solaris (thanks Brian Ripley)
* Moved to `file.path` uniformly (#7)

# etl 0.3.3

* Moved `is.etl` to main documentation for `etl` (30dee378)
* Fixed typo in DESCRIPTION (4e77fba2)
* Fixed bug in `etl_load.etl_mtcars` by making `etl_transform` safer
* Made `verify_con` messages easier to read
* Added new functions for help with computing dates and matching filenames to dates
* Added several tests
* Added `new_filenames` argument to `smart_download`
* Re-implemented `etl_init` (#7)
* Renamed `get_schema` to `find_schema` (1c0a4e3)

# etl 0.3.1

* Added a `NEWS.md` file to track changes to the package.



