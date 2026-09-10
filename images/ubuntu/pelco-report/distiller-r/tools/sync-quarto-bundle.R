#!/usr/bin/env Rscript
# Sync the Typst library code into the Quarto extension bundle.
#
# `inst/quarto/_extensions/distiller/distiller.typ` is DERIVED from the
# source-of-truth at the repo root (`../distiller.typ`). Never edit the
# copy by hand: `install_quarto_extension()` ships it verbatim, so a
# stale bundle means users compile against old Typst code while the repo
# looks correct.
#
# Usage:
#   cd r && Rscript tools/sync-quarto-bundle.R           regenerate
#   cd r && Rscript tools/sync-quarto-bundle.R --check    exit 1 if stale (CI)
#
# The tracked pre-commit hook in .githooks/ runs the regenerate step
# automatically when ../distiller.typ is staged (enable per clone with
# `git config core.hooksPath .githooks`). The GitHub Actions workflow
# runs --check as a backstop for clones without the hook.

args <- commandArgs(trailingOnly = TRUE)
check_only <- "--check" %in% args

src <- "../distiller.typ"
dst <- "inst/quarto/_extensions/distiller/distiller.typ"

if (!file.exists(src)) {
  stop("source not found: ", src, " (run from the r/ directory)")
}

if (check_only) {
  if (!file.exists(dst)) {
    cat("error:", dst, "is missing\n",
        "run `cd r && Rscript tools/sync-quarto-bundle.R` and commit the result\n",
        file = stderr())
    quit(status = 1)
  }
  same <- identical(readBin(src, "raw", file.size(src)),
                    readBin(dst, "raw", file.size(dst)))
  if (!same) {
    cat("error:", dst, "is out of date with", src, "\n",
        "run `cd r && Rscript tools/sync-quarto-bundle.R` and commit the result\n",
        file = stderr())
    quit(status = 1)
  }
  cat("ok:", dst, "is in sync with", src, "\n")
  quit(status = 0)
}

dir.create(dirname(dst), recursive = TRUE, showWarnings = FALSE)
ok <- file.copy(src, dst, overwrite = TRUE)
if (!ok) stop("copy failed: ", src, " -> ", dst)
cat("synced", src, "->", dst, "\n")
