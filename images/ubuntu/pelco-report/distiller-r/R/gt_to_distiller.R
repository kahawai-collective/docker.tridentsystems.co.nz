#' Convert a gt table to a distiller distiller-table() Typst call
#'
#' Extracts data, column labels, spanners, and row groups from a gt object
#' and generates the corresponding Typst code using distiller's distiller-table().
#'
#' @param gt_obj A gt table object.
#' @param caption Optional caption text. If NULL, uses gt's title.
#' @return A character string containing the Typst code.
#' @export
gt_to_distiller <- function(gt_obj, caption = NULL) {

  # Sanitise column name for Typst (dots → hyphens, quote if needed)
  sanitise_col <- function(name) {
    gsub(".", "-", name, fixed = TRUE)
  }

  # Extract formatted body data
  body <- gt::extract_body(gt_obj, output = "grid")

  # Extract column metadata from gt internals
  boxhead <- gt_obj[["_boxhead"]]
  spanner_data <- gt_obj[["_spanners"]]
  heading <- gt_obj[["_heading"]]

  # Determine which columns are visible
  visible_cols <- boxhead$var[boxhead$type == "default"]

  # Get column labels (display names)
  col_labels <- setNames(
    as.character(boxhead$column_label[boxhead$type == "default"]),
    boxhead$var[boxhead$type == "default"]
  )

  # Get column alignments
  col_aligns <- setNames(
    as.character(boxhead$column_align[boxhead$type == "default"]),
    boxhead$var[boxhead$type == "default"]
  )

  # Build the output data
  out_data <- body[, visible_cols, drop = FALSE]

  # Sanitise column names in the data
  safe_names <- sapply(visible_cols, sanitise_col)
  colnames(out_data) <- safe_names

  # Convert data frame to inline Typst 2D array
  typst_data <- df_to_typst_array(out_data)

  # Build the Typst columns spec
  col_lines <- vapply(visible_cols, function(col) {
    safe <- sanitise_col(col)
    label_text <- col_labels[[col]]
    align_str <- col_aligns[[col]]

    parts <- paste0("    ", safe, ": (label: [", label_text, "]")
    if (align_str == "right") {
      parts <- paste0(parts, ", align: right")
    } else if (align_str == "center") {
      parts <- paste0(parts, ", align: center")
    }
    paste0(parts, "),")
  }, character(1))

  # Build spanners
  spanner_lines <- character(0)
  if (!is.null(spanner_data) && nrow(spanner_data) > 0) {
    level1 <- spanner_data[spanner_data$spanner_level == 1, ]
    if (nrow(level1) > 0) {
      entries <- vapply(seq_len(nrow(level1)), function(i) {
        label <- as.character(level1$spanner_label[[i]])
        vars <- intersect(level1$vars[[i]], visible_cols)
        if (length(vars) == 0) return("")
        safe_vars <- sapply(vars, sanitise_col)
        var_str <- paste0('"', safe_vars, '"', collapse = ", ")
        paste0('    "', label, '": (', var_str, '),')
      }, character(1))
      entries <- entries[nchar(entries) > 0]
      if (length(entries) > 0) {
        spanner_lines <- c("  spanners: (", entries, "  ),")
      }
    }
  }

  # Build caption
  caption_text <- caption
  if (is.null(caption_text) && !is.null(heading$title)) {
    caption_text <- as.character(heading$title)
  }

  # Assemble Typst code
  lines <- c(
    "#figure(",
    "  distiller-table(",
    paste0("    ", typst_data, ","),
    "    columns: (",
    col_lines,
    "  ),"
  )

  if (length(spanner_lines) > 0) {
    lines <- c(lines, spanner_lines)
  }

  lines <- c(lines, "  ),")

  if (!is.null(caption_text) && nchar(caption_text) > 0) {
    lines <- c(lines, paste0("  caption: [", caption_text, "],"))
  }

  lines <- c(lines, "  kind: table,", ")")

  paste(lines, collapse = "\n")
}
