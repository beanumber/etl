## Test environments

* local Ubuntu 20.04.2 LTS, R 4.0.5
* Ubuntu 16.04.6 (on travis-ci), oldrel, release, devel
* Ubuntu Linux 20.04.1 LTS, R-release, GCC
* Fedora Linux, R-devel, clang, gfortran
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit

## R CMD check results

* Internet downloads are disabled for CRAN checks

* On Travis:

0 errors | 0 warnings | 0 notes

* On R-hub:

* checking package dependencies ... ERROR
Package suggested but not available: ‘RPostgreSQL’

  I don't think I can do anything about this. 

* Possibly mis-spelled words in DESCRIPTION:
  ETL (11:66)
  pipeable (11:32)

  These words are not mis-spelled.

* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Benjamin S. Baumer <ben.baumer@gmail.com>'
New maintainer:

  Benjamin S. Baumer <ben.baumer@gmail.com>
Old maintainer(s):
  Ben Baumer <ben.baumer@gmail.com>
  
  Still me -- I'm trying to be more consistent with my name. 

## Reverse dependencies

`macleish` and `mdsr` have both been checked.

---

