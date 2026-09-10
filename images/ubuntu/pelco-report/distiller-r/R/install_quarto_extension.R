#' Install the distiller Quarto extension into a project
#'
#' Copies the bundled Quarto extension (carrying a version-matched
#' `distiller.typ`) into `<project>/_extensions/distiller/`. After running
#' this, set the document format to `distiller-typst` in the Quarto YAML
#' and `distiller-table()` / `fmt()` / the kind system become available
#' to any `{=typst}` block, and to the `knit_print` path for gt tables.
#'
#' The installed Typst code is the exact version that ships with this R
#' package — there's no separate side-loaded `@local/distiller` install
#' to keep in sync.
#'
#' @param project Directory to install into. Defaults to the current
#'   working directory.
#' @param overwrite Replace an existing `_extensions/distiller/` if
#'   present. Default `TRUE` — re-running this is the recommended way
#'   to update the bundled Typst library after upgrading the R package.
#' @return Invisibly, the installed extension directory.
#' @export
#' @examples
#' \dontrun{
#' # Once per Quarto project:
#' distiller::install_quarto_extension()
#' # Then in the .qmd YAML:
#' #   format: distiller-typst
#' }
install_quarto_extension <- function(project = ".", overwrite = TRUE) {
  src <- system.file("quarto/_extensions/distiller", package = "distiller")
  if (!nzchar(src) || !dir.exists(src)) {
    stop(
      "distiller's bundled Quarto extension is missing from the package ",
      "install (looked under inst/quarto/_extensions/distiller). Reinstall ",
      "the R package."
    )
  }
  dst <- file.path(project, "_extensions", "distiller")
  if (dir.exists(dst)) {
    if (!overwrite) {
      message(
        "Extension already installed at ", normalizePath(dst, mustWork = FALSE),
        " (overwrite = FALSE, skipping)"
      )
      return(invisible(dst))
    }
    unlink(dst, recursive = TRUE)
  }
  dir.create(dst, recursive = TRUE, showWarnings = FALSE)
  ok <- file.copy(
    list.files(src, full.names = TRUE), dst,
    overwrite = TRUE, recursive = TRUE
  )
  if (!all(ok)) {
    stop("failed to copy some extension files into ", dst)
  }
  message(
    "Installed distiller Quarto extension to ",
    normalizePath(dst, mustWork = FALSE), ".\n",
    "  Set `format: distiller-typst` in your .qmd YAML to use it."
  )
  invisible(dst)
}
