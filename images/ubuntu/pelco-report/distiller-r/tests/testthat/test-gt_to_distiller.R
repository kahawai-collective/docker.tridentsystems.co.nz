test_that("gt_to_distiller generates valid Typst code", {
  tbl <- gt::gt(head(iris, 3)) |>
    gt::tab_header(title = "Test table")

  result <- gt_to_distiller(tbl)

  expect_true(grepl("#figure\\(", result))
  expect_true(grepl("distiller-table\\(", result))
  expect_true(grepl("caption: \\[Test table\\]", result))
  expect_true(grepl("Sepal-Length", result))
  expect_true(grepl("kind: table", result))
})

test_that("spanners are extracted correctly", {
  tbl <- gt::gt(head(iris, 3)) |>
    gt::tab_spanner(label = "Sepal", columns = c(Sepal.Length, Sepal.Width))

  result <- gt_to_distiller(tbl)

  expect_true(grepl('spanners:', result))
  expect_true(grepl('"Sepal"', result))
  expect_true(grepl('"Sepal-Length"', result))
  expect_true(grepl('"Sepal-Width"', result))
})

test_that("custom column labels are used", {
  d <- data.frame(x = 1:3, y = 4:6)
  tbl <- gt::gt(d) |>
    gt::cols_label(x = "Count", y = "Total")

  result <- gt_to_distiller(tbl)

  expect_true(grepl("label: \\[Count\\]", result))
  expect_true(grepl("label: \\[Total\\]", result))
})

test_that("data is embedded inline as Typst array", {
  tbl <- gt::gt(head(iris, 3))

  result <- gt_to_distiller(tbl)

  # Should contain inline array, not csv() call
  expect_false(grepl("csv\\(", result))
  expect_true(grepl("\\(\\(", result))
})
