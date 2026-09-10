test_that("install_quarto_extension copies the bundled extension", {
  tmp <- withr::local_tempdir()
  dst <- install_quarto_extension(project = tmp)

  expect_true(dir.exists(file.path(tmp, "_extensions", "distiller")))
  expect_true(file.exists(file.path(tmp, "_extensions", "distiller", "_extension.yml")))
  expect_true(file.exists(file.path(tmp, "_extensions", "distiller", "distiller.typ")))

  # _extension.yml carries the typst include-in-header injection.
  yml <- readLines(file.path(tmp, "_extensions", "distiller", "_extension.yml"))
  expect_true(any(grepl("include-in-header", yml)))
  expect_true(any(grepl('_extensions/distiller/distiller.typ', yml, fixed = TRUE)))
})

test_that("install_quarto_extension refuses overwrite when overwrite = FALSE", {
  tmp <- withr::local_tempdir()
  install_quarto_extension(project = tmp)
  # Drop a sentinel inside the existing install
  marker <- file.path(tmp, "_extensions", "distiller", "marker.txt")
  writeLines("hands off", marker)

  expect_message(
    install_quarto_extension(project = tmp, overwrite = FALSE),
    "skipping"
  )
  expect_true(file.exists(marker))   # untouched
})

test_that("install_quarto_extension refreshes content when overwrite = TRUE", {
  tmp <- withr::local_tempdir()
  install_quarto_extension(project = tmp)
  marker <- file.path(tmp, "_extensions", "distiller", "marker.txt")
  writeLines("transient", marker)

  install_quarto_extension(project = tmp, overwrite = TRUE)
  expect_false(file.exists(marker))   # cleared by re-install
})
