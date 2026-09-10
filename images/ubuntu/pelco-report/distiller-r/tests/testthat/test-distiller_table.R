test_that("render_typst generates simple table", {
  d <- data.frame(x = 1:3, y = c("a", "b", "c"))
  result <- render_typst(
    d,
    columns = list(x = col("Count"), y = col("Label")),
    spanners = NULL, dp = 0, group_by = NULL, group_order = NULL,
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = "Test table"
  )
  expect_true(grepl("distiller-table", result))
  expect_true(grepl('label: \\[Count\\]', result))
  expect_true(grepl('label: \\[Label\\]', result))
  expect_true(grepl('caption: \\[Test table\\]', result))
})

test_that("render_typst generates spanners", {
  d <- data.frame(a = 1:3, b = 4:6, c = 7:9)
  result <- render_typst(
    d,
    columns = list(a = col("A"), b = col("B"), c = col("C")),
    spanners = list("Group" = c("b", "c")), dp = 0,
    group_by = NULL, group_order = NULL,
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = NULL
  )
  expect_true(grepl("spanners:", result))
  expect_true(grepl('"Group"', result))
})

test_that("render_typst generates pivot", {
  d <- data.frame(row = rep(c("X", "Y"), 2), col = rep(c("A", "B"), each = 2), val = 1:4)
  result <- render_typst(
    d,
    columns = list(row = col("Row"), val = col("Value")),
    spanners = NULL, dp = 0, group_by = NULL, group_order = NULL,
    pivot = "col", pivot_order = c("A", "B"), pivot_labels = list(A = "Alpha", B = "Beta"),
    caption = NULL
  )
  expect_true(grepl('pivot: "col"', result))
  expect_true(grepl('pivot-order:', result))
  expect_true(grepl('pivot-labels:', result))
  # Typst dictionary keys must be quoted strings
  expect_true(grepl('"A": \\[Alpha\\]', result))
})

test_that("render_typst quotes numeric pivot-labels keys", {
  # A bare numeric key (e.g. a fishing year) parses as an integer in Typst
  # and fails to compile, so the emitter must quote every key.
  d <- data.frame(row = rep(c("X", "Y"), 2), yr = rep(c(2025, 2026), each = 2), val = 1:4)
  result <- render_typst(
    d,
    columns = list(row = col("Row"), val = col("Value")),
    spanners = NULL, dp = 0, group_by = NULL, group_order = NULL,
    pivot = "yr", pivot_order = c("2025", "2026"),
    pivot_labels = list(`2025` = "FY25", `2026` = "FY26"),
    caption = NULL
  )
  expect_true(grepl('"2025": \\[FY25\\]', result))
  expect_false(grepl('[^"]2025: \\[', result))
})

test_that("render_typst generates group-by", {
  d <- data.frame(grp = c("A", "A", "B", "B"), x = 1:4)
  result <- render_typst(
    d,
    columns = list(grp = col("Group"), x = col("Value")),
    spanners = NULL, dp = 0,
    group_by = "grp", group_order = c("A", "B"),
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = NULL
  )
  expect_true(grepl('group-by: "grp"', result))
  expect_true(grepl('group-order:', result))
})

test_that("render_typst generates nested group-by", {
  d <- data.frame(a = c("X", "X", "Y", "Y"), b = c("1", "2", "1", "2"), v = 1:4)
  result <- render_typst(
    d,
    columns = list(a = col("A"), b = col("B"), v = col("V")),
    spanners = NULL,
    dp = 0, group_by = c("a", "b"),
    group_order = list(a = c("X", "Y"), b = c("1", "2")),
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = NULL
  )
  expect_true(grepl('group-by: \\("a", "b"\\)', result))
  expect_true(grepl('a: \\("X", "Y"\\)', result))
})

test_that("render_typst maps fmt to dp", {
  d <- data.frame(x = c(1.234, 5.678))
  result <- render_typst(
    d,
    columns = list(x = col("Value", fmt = "%.1f")),
    spanners = NULL, dp = 0, group_by = NULL, group_order = NULL,
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = NULL
  )
  expect_true(grepl("dp: 1", result))
})

test_that("render_typst uses table-level dp", {
  d <- data.frame(x = c(1.234, 5.678), y = c("a", "b"))
  result <- render_typst(
    d,
    columns = list(x = col("Value"), y = col("Label")),
    spanners = NULL, dp = 2, group_by = NULL, group_order = NULL,
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = NULL
  )
  expect_true(grepl("dp: 2", result))
})

test_that("column-level dp overrides table dp in R", {
  d <- data.frame(x = c(1.234, 5.678))
  result <- render_typst(
    d,
    columns = list(x = col("Value", dp = 3)),
    spanners = NULL, dp = 1, group_by = NULL, group_order = NULL,
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = NULL
  )
  expect_true(grepl("dp: 3", result))
})

test_that("render_typst emits column kind for built-in and registered kinds", {
  d <- data.frame(year = c(2009, 2010), rate = c(0.785, 0.62))
  result <- render_typst(
    d,
    columns = list(
      year = col("Year", kind = "sy"),
      rate = col("Rate", kind = "fraction")
    ),
    spanners = NULL, dp = 0, group_by = NULL, group_order = NULL,
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = NULL
  )
  expect_true(grepl('kind: "sy"', result, fixed = TRUE))
  expect_true(grepl('kind: "fraction"', result, fixed = TRUE))
})

test_that("col(kind=) coexists with dp and align", {
  d <- data.frame(rate = c(0.025, 0.78))
  result <- render_typst(
    d,
    columns = list(rate = col("Rate", kind = "fraction", dp = 2, align = "right")),
    spanners = NULL, dp = 0, group_by = NULL, group_order = NULL,
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = NULL
  )
  expect_true(grepl('kind: "fraction"', result, fixed = TRUE))
  expect_true(grepl("dp: 2", result))
  expect_true(grepl("align: right", result, fixed = TRUE))
})

test_that("render_typst works with no columns (auto-generated)", {
  d <- data.frame(Name = c("Alice", "Bob"), Count = c(42, 37))
  # Auto-generate columns
  auto_cols <- setNames(lapply(names(d), function(nm) col(nm)), names(d))
  result <- render_typst(
    d,
    columns = auto_cols,
    spanners = NULL, dp = 0, group_by = NULL, group_order = NULL,
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = "Auto table"
  )
  expect_true(grepl("label: \\[Name\\]", result))
  expect_true(grepl("label: \\[Count\\]", result))
})

test_that("distiller_table auto-generates columns when NULL", {
  d <- data.frame(x = 1:3, y = c("a", "b", "c"))
  # Can't call distiller_table directly (needs knitr context)
  # but test the auto-generation logic
  auto_cols <- setNames(lapply(names(d), function(nm) col(nm)), names(d))
  expect_equal(names(auto_cols), c("x", "y"))
  expect_equal(auto_cols$x$label, "x")
  expect_equal(auto_cols$y$label, "y")
})

test_that("render_gt creates a gt object", {
  d <- data.frame(x = 1:3, y = c("a", "b", "c"))
  result <- render_gt(
    d,
    columns = list(x = col("Count"), y = col("Label")),
    spanners = NULL, dp = 0, group_by = NULL, group_order = NULL,
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = "Test"
  )
  expect_s3_class(result, "gt_tbl")
})

test_that("render_gt applies spanners", {
  d <- data.frame(a = 1:3, b = 4:6, c = 7:9)
  result <- render_gt(
    d,
    columns = list(a = col("A"), b = col("B"), c = col("C")),
    spanners = list("Group" = c("b", "c")), dp = 0,
    group_by = NULL, group_order = NULL,
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = NULL
  )
  expect_s3_class(result, "gt_tbl")
  # Check spanner exists in gt internals
  expect_true(nrow(result[["_spanners"]]) > 0)
  expect_equal(as.character(result[["_spanners"]]$spanner_label[[1]]), "Group")
})

test_that("render_gt applies group-by", {
  d <- data.frame(grp = c("A", "A", "B", "B"), x = 1:4)
  result <- render_gt(
    d,
    columns = list(grp = col("Group"), x = col("Value")),
    spanners = NULL, dp = 0,
    group_by = "grp", group_order = c("A", "B"),
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = NULL
  )
  expect_s3_class(result, "gt_tbl")
  # Group column should be used for row groups, not in body
  html <- as.character(gt::as_raw_html(result))
  expect_true(grepl("gt_group_heading", html))
})

test_that("render_gt applies nested group-by", {
  d <- data.frame(a = c("X", "X", "Y", "Y"), b = c("1", "2", "1", "2"), v = 1:4)
  result <- render_gt(
    d,
    columns = list(a = col("A"), b = col("B"), v = col("V")),
    spanners = NULL, dp = 0,
    group_by = c("a", "b"),
    group_order = list(a = c("X", "Y"), b = c("1", "2")),
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = NULL
  )
  expect_s3_class(result, "gt_tbl")
  html <- as.character(gt::as_raw_html(result))
  # Should have combined group headers
  expect_true(grepl("X .* 1", html))
})

test_that("render_gt applies function fmt", {
  lookup <- gloss(c(A = "Alpha", B = "Beta"))
  d <- data.frame(code = c("A", "B"), val = 1:2)
  result <- render_gt(
    d,
    columns = list(code = col("Code", fmt = lookup), val = col("Value")),
    spanners = NULL, dp = 0, group_by = NULL, group_order = NULL,
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = NULL
  )
  expect_s3_class(result, "gt_tbl")
  html <- as.character(gt::as_raw_html(result))
  expect_true(grepl("Alpha", html))
  expect_true(grepl("Beta", html))
  expect_false(grepl(">A<", html))
})

test_that("render_gt left-aligns character columns", {
  d <- data.frame(name = c("Alice", "Bob"), score = c(95, 87))
  result <- render_gt(
    d,
    columns = list(name = col("Name"), score = col("Score")),
    spanners = NULL, dp = 0, group_by = NULL, group_order = NULL,
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = NULL
  )
  html <- as.character(gt::as_raw_html(result))
  # Name column should be left-aligned
  expect_true(grepl("gt_left.*Name|Name.*gt_left", html))
})

test_that("render_gt applies fmt none", {
  d <- data.frame(year = c(2004L, 2015L), val = c(1234.5, 6789.1))
  result <- render_gt(
    d,
    columns = list(year = col("Year", fmt = "none"), val = col("Value", dp = 1)),
    spanners = NULL, dp = 0, group_by = NULL, group_order = NULL,
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = NULL
  )
  html <- as.character(gt::as_raw_html(result))
  expect_true(grepl("2004", html))
  expect_false(grepl("2,004", html))
})

test_that("render_gt applies booktabs styling", {
  d <- data.frame(x = 1:3, y = 4:6)
  result <- render_gt(
    d,
    columns = list(x = col("X"), y = col("Y")),
    spanners = NULL, dp = 0, group_by = NULL, group_order = NULL,
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = NULL
  )
  # Check tab_options were applied (no striping)
  opts <- result[["_options"]]
  striping_opt <- opts[opts$parameter == "row_striping_include_table_body", "value"][[1]]
  expect_false(striping_opt)
})

test_that("render_typst handles function fmt gracefully", {
  g <- gloss(c(A = "Alpha"))
  d <- data.frame(code = c("A", "B"))
  # Function fmt should not break Typst rendering (just ignored)
  result <- render_typst(
    d,
    columns = list(code = col("Code", fmt = g)),
    spanners = NULL, dp = 0, group_by = NULL, group_order = NULL,
    pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
    caption = NULL
  )
  expect_true(grepl("distiller-table", result))
  expect_true(grepl("label: \\[Code\\]", result))
})
