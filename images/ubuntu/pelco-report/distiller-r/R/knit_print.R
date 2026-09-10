#' Custom knit_print method for gt tables targeting Typst
#'
#' When rendering to Typst (via Quarto), this method converts gt tables
#' to distiller distiller-table() calls. For all other formats, it falls through
#' to gt's default knit_print method.
#'
#' @param x A gt table object.
#' @param ... Additional arguments passed to knit_print.
#' @return A knit_asis object containing the Typst code.
#' @export
knit_print.gt_tbl <- function(x, ...) {
  output_format <- knitr::pandoc_to()

  if (!is.null(output_format) && output_format == "typst") {
    typst_code <- gt_to_distiller(x)
    knitr::asis_output(paste0("\n```{=typst}\n", typst_code, "\n```\n"))
  } else {
    # Fall through to gt's default method
    gt_print <- utils::getFromNamespace("knit_print.gt_tbl", "gt")
    gt_print(x, ...)
  }
}

#' Register the distiller knit_print method for gt tables
#'
#' Call this in your setup chunk to enable automatic conversion of gt
#' tables to distiller format when rendering to Typst.
#'
#' @return NULL (invisibly). Called for its side effect of registering
#'   the S3 method.
#' @export
#' @examples
#' \dontrun{
#' # In a Quarto document setup chunk:
#' library(distiller)
#' register_distiller()
#' }
register_distiller <- function() {
  registerS3method("knit_print", "gt_tbl", knit_print.gt_tbl,
                   envir = asNamespace("knitr"))
  invisible(NULL)
}
