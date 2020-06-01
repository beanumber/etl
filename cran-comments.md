## Test environments

* local Ubuntu 18.04.3, R 3.6.3
* Ubuntu 16.04.6 (on travis-ci), oldrel, release, devel
* Ubuntu Linux 16.04 LTS, R-release, GCC
* Fedora Linux, R-devel, clang, gfortran
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit

## R CMD check results

* This is a resubmission. The package was pulled from CRAN
  because of a change in `usethis`, but that issue is resolved.

* Internet downloads are disabled for CRAN checks

* On Travis:

0 errors | 0 warnings | 0 notes

* On R-hub:

* Possibly mis-spelled words in DESCRIPTION:
  ETL (11:66)
  pipeable (11:32)

  These words are not mis-spelled.

* R-hub throws an error on Windows Server 2008 R2 SP1, R-devel, 32/64 bit
Error: package or namespace load failed for 'dplyr' in loadNamespace(i, c(lib.loc, .libPaths()), versionCheck = vI[[i]]):
 namespace 'vctrs' 0.2.4 is being loaded, but >= 0.3.0 is required
Error: package 'dplyr' could not be loaded

  This seems like an issue with R-hub on Windows and `dplyr` so it's outside of my control.


## Reverse dependencies

`macleish` and `mdsr` have both been checked.

---

