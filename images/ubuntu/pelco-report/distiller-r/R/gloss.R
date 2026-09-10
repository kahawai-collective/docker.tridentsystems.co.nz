#' Create a glossary lookup function from a JSON file or named list
#'
#' Returns a function that maps codes to their expansions.
#' Unknown codes are returned unchanged.
#'
#' @param labels Path to a JSON file, or a named character vector / list.
#' @return A function of class "distiller_gloss" that takes a code (or vector
#'   of codes) and returns the expansion(s).
#' @export
gloss <- function(labels) {
  if (is.character(labels) && length(labels) == 1 && file.exists(labels)) {
    labels <- jsonlite::fromJSON(labels)
  }
  labels <- as.list(labels)
  f <- function(code) {
    vapply(code, function(x) {
      if (x %in% names(labels)) as.character(labels[[x]]) else x
    }, character(1), USE.NAMES = FALSE)
  }
  class(f) <- c("distiller_gloss", "function")
  f
}

#' Create an acronym tracker from a JSON file or named list
#'
#' On first use of a code, expands to "full name (CODE)".
#' On subsequent uses, returns just "CODE".
#'
#' @param labels Path to a JSON file, or a named character vector / list.
#' @return A function that takes a code and returns the appropriate expansion.
#' @export
acr <- function(labels) {
  if (is.character(labels) && length(labels) == 1 && file.exists(labels)) {
    labels <- jsonlite::fromJSON(labels)
  }
  labels <- as.list(labels)
  used <- character(0)
  env <- environment()
  f <- function(code) {
    vapply(code, function(x) {
      if (x %in% env$used) {
        x
      } else {
        env$used <- c(env$used, x)
        expansion <- if (x %in% names(labels)) as.character(labels[[x]]) else x
        paste0(expansion, " (", x, ")")
      }
    }, character(1), USE.NAMES = FALSE)
  }
  f
}

#' Capitalise the first letter of a string
#'
#' @param x Character vector.
#' @return Character vector with first letter capitalised.
#' @export
cap <- function(x) {
  paste0(toupper(substring(x, 1, 1)), substring(x, 2))
}
