#' My ETL functions
#' @import etl
#' @inheritParams etl::etl_extract
#' @export
#' @examples
#' \dontrun{
#' if (require(dplyr)) {
#'   obj <- etl("foo") %>%
#'     etl_create()
#' }
#' }

etl_extract.etl_foo <- function(obj, ...) {
  # Specify the URLs that you want to download
  src <- c("https://ed-public-download.app.cloud.gov/downloads/Most-Recent-Cohorts-Scorecard-Elements.csv")

  # Use the smart_download() function for convenience
  etl::smart_download(obj, src, ...)

  # Always return obj invisibly to ensure pipeability!
  invisible(obj)
}
