## Test environments

* local Ubuntu 18.04.3, R 3.6.3
* Ubuntu 16.04.6 (on travis-ci), oldrel, release, devel
* Ubuntu Linux 16.04 LTS, R-release, GCC
* Fedora Linux, R-devel, clang, gfortran
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit

## R CMD check results

* Internet downloads are disabled for CRAN checks

* On Travis:

0 errors | 0 warnings | 0 notes

* On R-hub

* Possibly mis-spelled words in DESCRIPTION:
  ETL (11:66)
  pipeable (11:32)

  These words are not mis-spelled.

* Windows throws a NOTE, but this doesn't happen on any other platforms, 
  so I am inclined to ignore it:
    * checking examples ... NOTE
    Examples with CPU (user + system) or elapsed time > 5s
                   user system elapsed
    smart_download    0   0.06   11.65

* R-hub throws an ERROR on Fedora and Ubuntu, but the error is caused by `sf` 
  failing to install due to GDAL libraries being behind schedule:
    * checking package dependencies ... ERROR
    Package suggested but not available: ‘macleish’

* R-hub throws an ERROR on Fedora, but the error is caused by external 
  dependencies not being met that I can't control:
    * checking package dependencies ... ERROR
    Packages suggested but not available: 'RPostgreSQL', 'RMySQL'

## Reverse dependencies

`macleish` and `mdsr` have both been checked.

---

