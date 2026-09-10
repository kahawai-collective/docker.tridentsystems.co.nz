# Demonstrate gt_to_distiller with the three example tables
library(gt)
library(data.table)
source("R/gt_to_distiller.R")

# ── Table 1: Simple table (stations) ──────────────────────

stations <- fread("../example/tables/stations.csv")

tbl1 <- gt(stations) |>
  cols_label(
    region = "Region",
    type = "Type",
    n_stations = "Stations",
    coverage_pct = "Coverage (%)",
    start_year = "Start year"
  ) |>
  tab_header(title = "Monitoring station coverage by region and measurement type.")

cat("=== Table 1: Simple ===\n")
cat(gt_to_distiller(tbl1, csv_path = "/tmp/demo-stations.csv"), "\n\n")


# ── Table 2: Pivoted table (anomalies by region) ─────────
# gt doesn't have native pivoting, so we pivot in R first
# then use spanners to create the grouped header structure

anomalies <- fread("../example/tables/anomalies-by-region.csv")

# Pivot wide: one row per decade, columns for each region's mean/lower/upper
wide <- dcast(anomalies, decade ~ region, value.var = c("mean", "lower", "upper"))

tbl2 <- gt(wide) |>
  cols_label(
    decade = "Decade",
    mean_NH = "Mean", lower_NH = "Lower", upper_NH = "Upper",
    mean_SH = "Mean", lower_SH = "Lower", upper_SH = "Upper",
    mean_GL = "Mean", lower_GL = "Lower", upper_GL = "Upper"
  ) |>
  tab_spanner(label = "Northern Hemisphere", columns = c(mean_NH, lower_NH, upper_NH)) |>
  tab_spanner(label = "Southern Hemisphere", columns = c(mean_SH, lower_SH, upper_SH)) |>
  tab_spanner(label = "Global", columns = c(mean_GL, lower_GL, upper_GL)) |>
  fmt_number(columns = where(is.numeric), decimals = 2) |>
  tab_header(
    title = "Temperature anomalies by decade and region.",
    subtitle = "Values are the mean and 95% confidence interval."
  )

cat("=== Table 2: Pivoted (via R pivot + gt spanners) ===\n")
cat(gt_to_distiller(tbl2, csv_path = "/tmp/demo-anomalies.csv"), "\n\n")

# Alternative: use distiller's pivot directly (just pass the tidy CSV)
# This is what the Typst example does — no R pivot needed.
cat("=== Table 2 alternative: pass tidy data, let distiller pivot ===\n")
cat('The Typst example uses distiller\'s pivot parameter directly:\n')
cat('  distiller-table(csv("anomalies.csv"), columns: (...), pivot: "region")\n')
cat('This avoids the R pivot step entirely.\n\n')


# ── Table 3: Grouped row table (contributors) ────────────
# Distiller's group-by suppresses repeated values and adds spacing.
# gt's row groups add a header row above each group — different style.
# To match distiller's style, we DON'T use gt's groupname_col.
# Instead, we just pass the data as-is and let distiller handle grouping.

contributors <- fread("../example/tables/contributors.csv")

# With gt, we can try groupname_col but it produces a different layout
# (group label as a spanning row). Let's see what gt_to_distiller produces:
tbl3 <- gt(contributors) |>
  cols_label(
    source = "Source",
    region = "Region",
    type = "Type",
    n_stations = "Stations",
    quality_score = "Quality"
  ) |>
  cols_hide(years_active) |>
  tab_header(title = "Contributing data sources by region.")

cat("=== Table 3: Grouped (flat data, distiller handles grouping) ===\n")
cat(gt_to_distiller(tbl3, csv_path = "/tmp/demo-contributors.csv"), "\n\n")

cat("Note: For Table 3, the Typst code would need group-by added manually:\n")
cat('  group-by: ("source", "region"),\n')
cat('  group-order: (source: ("NOAA", "Met Office", "JMA"), region: ("NH", "SH")),\n')
