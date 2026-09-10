#' Define a column specification for distiller_table
#'
#' @param label Display label for the column header.
#' @param kind Kind name for the Typst backend. One of the built-in kinds
#'   ("int", "float", "pct", "fraction", "sy", "date", "bool", "markup",
#'   "ci", "mci", "qty"), a unit string ("m", "t/ha", ...), or a user-
#'   registered kind. Has no effect on the gt backend, which uses fmt/dp
#'   directly. Default NULL means rely on auto-detection from data type.
#' @param fmt Format string (sprintf-style, e.g. "%.1f") or function.
#'   For Typst output, maps to distiller's fmt parameter.
#'   For gt output, used via fmt_number or custom formatting.
#'   Overrides both column-level dp and table-level dp.
#' @param dp Decimal places for this column. Overrides table-level dp.
#' @param align Column alignment: "left", "right", or "center".
#'   Default NULL means auto-detect (numeric columns = right,
#'   text columns = left). Passed through to both Typst and HTML backends.
#' @param width Column width as a string with units, e.g. "4cm", "120pt",
#'   "2in", "50%". Passed directly to both Typst and HTML (gt) backends.
#'   Typst supports cm, mm, in, pt, em; gt/HTML also supports % and px.
#'   Default NULL means auto-size from content.
#' @return A list with class "distiller_col".
#' @export
col <- function(label, kind = NULL, fmt = NULL, dp = NULL,
                align = NULL, width = NULL) {
  structure(
    list(label = label, kind = kind, fmt = fmt, dp = dp,
         align = align, width = width),
    class = "distiller_col"
  )
}

#' Create a data-driven table that renders to distiller (Typst) or gt (HTML/LaTeX)
#'
#' @param data A data frame.
#' @param columns A named list of col() specifications (optional). Names must
#'   match data column names. Column order follows the list order. Columns not
#'   listed are hidden. If NULL, all columns are shown with labels taken from
#'   column names.
#' @param spanners A named list mapping spanner labels to character vectors
#'   of column names, e.g. list("Sepal" = c("sl_mean", "sl_sd")).
#' @param group_by Column name(s) for row grouping. Scalar or character vector.
#' @param group_order Group display order. For single group_by, a character
#'   vector. For multiple, a named list.
#' @param pivot Column name to pivot on (distiller-native, approximated in gt).
#' @param pivot_order Character vector of pivot values in display order.
#' @param pivot_labels Named list mapping pivot values to display labels.
#' @param dp Default decimal places for all numeric columns (default: 0).
#'   Overridden by column-level dp or fmt.
#' @param caption Table caption.
#' @return Rendered table (gt object for HTML/LaTeX, knitr::asis_output for Typst).
#' @export
distiller_table <- function(
  data,
  columns = NULL,
  spanners = NULL,
  dp = 0,
  group_by = NULL,
  group_order = NULL,
  pivot = NULL,
  pivot_order = NULL,
  pivot_labels = NULL,
  caption = NULL
) {
  # Auto-generate columns from data if not provided
  if (is.null(columns)) {
    columns <- setNames(
      lapply(names(data), function(nm) col(nm)),
      names(data)
    )
  }

  output_format <- knitr::pandoc_to()

  if (!is.null(output_format) && output_format == "typst") {
    typst_code <- render_typst(data, columns, spanners, dp, group_by, group_order,
                               pivot, pivot_order, pivot_labels, caption)
    knitr::asis_output(paste0("\n```{=typst}\n", typst_code, "\n```\n"))
  } else {
    render_gt(data, columns, spanners, dp, group_by, group_order,
              pivot, pivot_order, pivot_labels, caption)
  }
}

# ── Helpers ───────────────────────────────────────────────

# Convert a data frame to an inline Typst 2D array string.
# Produces the same structure as Typst's csv() function: a header row
# followed by data rows, all values as strings.
df_to_typst_array <- function(df) {
  escape_typst_str <- function(x) {
    x <- as.character(x)
    x[is.na(x)] <- ""
    x <- gsub("\\", "\\\\", x, fixed = TRUE)
    x <- gsub('"', '\\"', x, fixed = TRUE)
    x
  }
  header <- paste0('"', escape_typst_str(colnames(df)), '"', collapse = ", ")
  rows <- vapply(seq_len(nrow(df)), function(i) {
    vals <- vapply(df[i, , drop = FALSE], function(v) {
      paste0('"', escape_typst_str(v), '"')
    }, character(1))
    paste0("(", paste(vals, collapse = ", "), ")")
  }, character(1))
  paste0("((", header, "), ", paste(rows, collapse = ", "), ")")
}

# ── Typst backend ─────────────────────────────────────────

render_typst <- function(data, columns, spanners, dp, group_by, group_order,
                         pivot, pivot_order, pivot_labels, caption) {

  # Sanitise column names for Typst (dots → hyphens)
  sanitise <- function(name) gsub(".", "-", name, fixed = TRUE)

  col_names <- names(columns)

  # Select and order columns (keep group_by and pivot cols even if not in columns)
  extra_cols <- c(group_by, pivot)
  extra_cols <- extra_cols[!extra_cols %in% col_names]
  keep_cols <- unique(c(extra_cols, col_names))
  keep_cols <- intersect(keep_cols, names(data))
  out_data <- as.data.frame(data)[, keep_cols, drop = FALSE]

  # Sanitise column names in the output data
  colnames(out_data) <- sapply(colnames(out_data), sanitise)

  # Convert data frame to inline Typst 2D array
  typst_data <- df_to_typst_array(out_data)

  # Build column specs (sanitise names for Typst)
  col_lines <- vapply(col_names, function(nm) {
    spec <- columns[[nm]]
    safe_nm <- sanitise(nm)
    parts <- paste0("    ", safe_nm, ": (label: [", spec$label, "]")
    if (!is.null(spec$kind)) {
      # Kind dispatch (e.g. "pct", "fraction", "sy", "markup", a unit
      # string). Coexists with fmt/dp — distiller-table's precedence
      # is fmt > kind > dp.
      parts <- paste0(parts, ', kind: "', spec$kind, '"')
    }
    if (!is.null(spec$fmt) && identical(spec$fmt, "none")) {
      # fmt = "none" — disable auto-formatting (years, IDs, codes)
      parts <- paste0(parts, ", fmt: none")
    } else if (!is.null(spec$fmt)) {
      # Full custom formatter — extract dp from sprintf pattern
      if (is.character(spec$fmt)) {
        dp_match <- regmatches(spec$fmt, regexpr("\\.(\\d+)f", spec$fmt))
        if (length(dp_match) > 0 && nchar(dp_match) > 0) {
          col_dp <- as.integer(sub("\\.(\\d+)f", "\\1", dp_match))
          parts <- paste0(parts, ", dp: ", col_dp)
        }
      }
    } else if (!is.null(spec$dp)) {
      # Column-level dp override
      parts <- paste0(parts, ", dp: ", spec$dp)
    }
    if (!is.null(spec$align)) {
      parts <- paste0(parts, ", align: ", spec$align)
    }
    if (!is.null(spec$width)) {
      parts <- paste0(parts, ', width: ', spec$width)
    }
    paste0(parts, "),")
  }, character(1))

  # Build spanners (sanitise column references)
  spanner_lines <- character(0)
  if (!is.null(spanners)) {
    entries <- vapply(names(spanners), function(label) {
      vars <- spanners[[label]]
      safe_vars <- sapply(vars, sanitise)
      var_str <- paste0('"', safe_vars, '"', collapse = ", ")
      paste0('    "', label, '": (', var_str, '),')
    }, character(1))
    spanner_lines <- c("  spanners: (", entries, "  ),")
  }

  # Build pivot
  pivot_lines <- character(0)
  if (!is.null(pivot)) {
    pivot_lines <- c(paste0('  pivot: "', pivot, '",'))
    if (!is.null(pivot_order)) {
      po_str <- paste0('"', pivot_order, '"', collapse = ", ")
      pivot_lines <- c(pivot_lines, paste0("  pivot-order: (", po_str, "),"))
    }
    if (!is.null(pivot_labels)) {
      # Typst dictionary keys must be strings: an unquoted numeric-looking
      # key (e.g. a fishing year) parses as an integer and fails to compile.
      pl_entries <- vapply(names(pivot_labels), function(k) {
        paste0("    ", encodeString(k, quote = '"'), ": [", pivot_labels[[k]], "],")
      }, character(1))
      pivot_lines <- c(pivot_lines, "  pivot-labels: (", pl_entries, "  ),")
    }
  }

  # Build group-by
  group_lines <- character(0)
  if (!is.null(group_by)) {
    if (length(group_by) == 1) {
      group_lines <- paste0('  group-by: "', group_by, '",')
    } else {
      gb_str <- paste0('"', group_by, '"', collapse = ", ")
      group_lines <- paste0("  group-by: (", gb_str, "),")
    }
    if (!is.null(group_order)) {
      if (is.list(group_order)) {
        go_entries <- vapply(names(group_order), function(k) {
          vals <- paste0('"', group_order[[k]], '"', collapse = ", ")
          paste0("    ", k, ": (", vals, "),")
        }, character(1))
        group_lines <- c(group_lines, "  group-order: (", go_entries, "  ),")
      } else {
        go_str <- paste0('"', group_order, '"', collapse = ", ")
        group_lines <- c(group_lines, paste0("  group-order: (", go_str, "),"))
      }
    }
  }

  # Assemble
  lines <- c(
    "#figure(",
    "  distiller-table(",
    paste0("    ", typst_data, ","),
    "    columns: (",
    col_lines,
    "  ),"
  )

  if (dp != 0) lines <- c(lines, paste0("  dp: ", dp, ","))
  if (length(spanner_lines) > 0) lines <- c(lines, spanner_lines)
  if (length(pivot_lines) > 0) lines <- c(lines, pivot_lines)
  if (length(group_lines) > 0) lines <- c(lines, group_lines)

  lines <- c(lines, "  ),")
  if (!is.null(caption)) {
    lines <- c(lines, paste0("  caption: [", caption, "],"))
  }
  lines <- c(lines, "  kind: table,", ")")

  paste(lines, collapse = "\n")
}

# ── gt backend ────────────────────────────────────────────

render_gt <- function(data, columns, spanners, dp, group_by, group_order,
                      pivot, pivot_order, pivot_labels, caption) {

  col_names <- names(columns)

  # Handle pivot: expand data wide for gt
  if (!is.null(pivot)) {
    pivot_vals <- if (!is.null(pivot_order)) pivot_order else unique(data[[pivot]])
    # Identify value columns (columns in spec that aren't the pivot or row keys)
    non_pivot_data_cols <- setdiff(col_names, pivot)
    non_pivot_data_cols <- intersect(non_pivot_data_cols, names(data))
    row_cols <- setdiff(non_pivot_data_cols, names(data))
    # Simple approach: use reshape
    row_id_cols <- setdiff(col_names[col_names %in% names(data)], c(pivot, non_pivot_data_cols))
    if (length(row_id_cols) == 0) {
      # Infer row ID columns: columns whose values repeat per pivot group
      for (cn in names(data)) {
        if (cn == pivot || cn %in% non_pivot_data_cols) next
        row_id_cols <- c(row_id_cols, cn)
      }
    }
    # For now, fall through to flat gt if pivot is complex
  }

  # Select columns
  visible_cols <- intersect(col_names, names(data))
  tbl_data <- as.data.frame(data)[, visible_cols, drop = FALSE]

  # Handle group_by: create a combined group column for gt
  if (!is.null(group_by)) {
    gb_cols <- intersect(group_by, names(data))
    if (length(gb_cols) > 0) {
      # Build group label from group_by columns
      tbl_data$.group <- do.call(paste, c(
        lapply(gb_cols, function(g) data[[g]]),
        list(sep = " \u2014 ")
      ))
      # Order groups if group_order provided
      if (!is.null(group_order)) {
        if (is.list(group_order)) {
          # Expand ordered combinations
          ordered_groups <- do.call(expand.grid, c(rev(group_order), list(stringsAsFactors = FALSE)))
          ordered_groups <- ordered_groups[, rev(seq_len(ncol(ordered_groups))), drop = FALSE]
          lvls <- do.call(paste, c(ordered_groups, list(sep = " \u2014 ")))
        } else {
          lvls <- group_order
        }
        tbl_data$.group <- factor(tbl_data$.group, levels = lvls)
        tbl_data <- tbl_data[order(tbl_data$.group), , drop = FALSE]
      }
      # Remove group_by columns from visible cols
      visible_cols <- setdiff(visible_cols, gb_cols)
      tbl_data <- tbl_data[, c(".group", visible_cols), drop = FALSE]
    }
  }

  # Create gt
  if (!is.null(group_by) && ".group" %in% names(tbl_data)) {
    tbl <- gt::gt(tbl_data, groupname_col = ".group")
  } else {
    tbl <- gt::gt(tbl_data)
  }

  # Apply column labels
  labels_list <- setNames(
    lapply(columns[visible_cols], function(s) s$label),
    visible_cols
  )
  tbl <- gt::cols_label(tbl, .list = labels_list)

  # Apply column alignment — explicit spec wins, otherwise auto-detect
  for (nm in visible_cols) {
    spec <- columns[[nm]]
    if (!is.null(spec$align)) {
      tbl <- gt::cols_align(tbl, align = spec$align, columns = nm)
    } else if (is.character(tbl_data[[nm]]) || is.factor(tbl_data[[nm]])) {
      tbl <- gt::cols_align(tbl, align = "left", columns = nm)
    }
  }

  # Apply column widths — gt accepts CSS strings directly (e.g., "4cm", "50%")
  for (nm in visible_cols) {
    spec <- columns[[nm]]
    if (!is.null(spec$width)) {
      tbl <- gt::cols_width(tbl, !!rlang::sym(nm) := spec$width)
    }
  }

  # Apply formatting: function fmt > fmt "none" > column dp > table dp
  for (nm in visible_cols) {
    spec <- columns[[nm]]
    col_dp <- NULL
    if (!is.null(spec$fmt) && is.function(spec$fmt)) {
      # Function formatter (e.g., gloss lookup) — apply to column values
      # Force evaluation of fmt to avoid closure capture issues
      local({
        fmt_fn <- spec$fmt
        col_nm <- nm
        tbl <<- gt::text_transform(tbl, locations = gt::cells_body(columns = col_nm),
          fn = function(x) fmt_fn(x))
      })
    } else if (!is.null(spec$fmt) && identical(spec$fmt, "none")) {
      # fmt = "none" — skip formatting entirely for this column
      next
    } else if (!is.null(spec$fmt) && is.character(spec$fmt)) {
      dp_match <- regmatches(spec$fmt, regexpr("\\.(\\d+)f", spec$fmt))
      if (length(dp_match) > 0 && nchar(dp_match) > 0) {
        col_dp <- as.integer(sub("\\.(\\d+)f", "\\1", dp_match))
      }
    } else if (!is.null(spec$dp)) {
      col_dp <- spec$dp
    } else if (is.numeric(tbl_data[[nm]])) {
      col_dp <- dp  # table-level default
    }
    if (!is.null(col_dp) && is.numeric(tbl_data[[nm]])) {
      tbl <- gt::fmt_number(tbl, columns = nm, decimals = col_dp)
    }
  }

  # Apply spanners
  if (!is.null(spanners)) {
    for (label in names(spanners)) {
      cols <- spanners[[label]]
      cols <- intersect(cols, visible_cols)
      if (length(cols) > 0) {
        tbl <- gt::tab_spanner(tbl, label = label, columns = cols)
      }
    }
  }

  # Apply caption
  if (!is.null(caption)) {
    tbl <- gt::tab_header(tbl, title = caption)
  }

  # Hide columns not in spec
  hide_cols <- setdiff(names(data), col_names)
  if (length(hide_cols) > 0) {
    tbl <- gt::cols_hide(tbl, columns = hide_cols)
  }

  # Booktabs-style: no row striping, no vertical borders
  tbl <- gt::tab_options(
    tbl,
    table.border.top.style = "solid",
    table.border.top.width = gt::px(2),
    table.border.top.color = "#414141",
    table.border.bottom.style = "solid",
    table.border.bottom.width = gt::px(2),
    table.border.bottom.color = "#414141",
    table_body.hlines.style = "none",
    column_labels.border.top.style = "none",
    column_labels.border.bottom.style = "solid",
    column_labels.border.bottom.width = gt::px(1),
    column_labels.border.bottom.color = "#414141",
    row.striping.include_table_body = FALSE,
    row.striping.include_stub = FALSE,
    column_labels.font.weight = "bold"
  )

  tbl
}
