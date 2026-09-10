test_that("gloss creates lookup from named list", {
  g <- gloss(c(ETS = "emissions trading scheme", FMA = "field measurement approach"))
  expect_equal(g("ETS"), "emissions trading scheme")
  expect_equal(g("FMA"), "field measurement approach")
})

test_that("gloss returns code unchanged for unknown keys", {
  g <- gloss(c(ETS = "emissions trading scheme"))
  expect_equal(g("UNKNOWN"), "UNKNOWN")
})

test_that("gloss vectorises over multiple codes", {
  g <- gloss(c(A = "alpha", B = "beta", C = "gamma"))
  expect_equal(g(c("A", "C", "X")), c("alpha", "gamma", "X"))
})

test_that("gloss loads from JSON file", {
  tmp <- tempfile(fileext = ".json")
  jsonlite::write_json(list(SBD = "seabirds", FUR = "fur seal"), tmp, auto_unbox = TRUE)
  g <- gloss(tmp)
  expect_equal(g("SBD"), "seabirds")
  expect_equal(g("FUR"), "fur seal")
  unlink(tmp)
})

test_that("acr expands on first use, code only on subsequent", {
  a <- acr(c(ETS = "emissions trading scheme"))
  expect_equal(a("ETS"), "emissions trading scheme (ETS)")
  expect_equal(a("ETS"), "ETS")
})

test_that("acr handles multiple codes independently", {
  a <- acr(c(ETS = "emissions trading scheme", FMA = "field measurement approach"))
  expect_equal(a("ETS"), "emissions trading scheme (ETS)")
  expect_equal(a("FMA"), "field measurement approach (FMA)")
  expect_equal(a("ETS"), "ETS")
  expect_equal(a("FMA"), "FMA")
})

test_that("acr returns code unchanged for unknown keys", {
  a <- acr(c(ETS = "emissions trading scheme"))
  expect_equal(a("UNKNOWN"), "UNKNOWN (UNKNOWN)")
  expect_equal(a("UNKNOWN"), "UNKNOWN")
})

test_that("acr vectorises", {
  a <- acr(c(A = "alpha", B = "beta"))
  result <- a(c("A", "B"))
  expect_equal(result, c("alpha (A)", "beta (B)"))
  result2 <- a(c("A", "B"))
  expect_equal(result2, c("A", "B"))
})

test_that("cap capitalises first letter", {
  expect_equal(cap("hello"), "Hello")
  expect_equal(cap("Hello"), "Hello")
  expect_equal(cap("white-capped albatross"), "White-capped albatross")
})

test_that("cap vectorises", {
  expect_equal(cap(c("foo", "bar")), c("Foo", "Bar"))
})

test_that("gloss works as fmt in col()", {
  g <- gloss(c(A = "Alpha", B = "Beta"))
  spec <- col("Label", fmt = g)
  expect_true(is.function(spec$fmt))
  expect_equal(spec$fmt("A"), "Alpha")
})
