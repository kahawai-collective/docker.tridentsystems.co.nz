# Demonstrate distiller_table() Typst output
# Test the render_typst function directly
library(data.table)
source("R/distiller_table.R")

# Access the internal render function directly for testing
# (In real use, distiller_table() auto-detects the output format)

# Helper to generate Typst code outside knitr context
typst_table <- function(...) {
  # Temporarily mock knitr functions
  env <- environment(render_typst)
  old_label <- knitr::opts_current$get("label")
  render_typst(...)
}

# ── Table 1: Simple table ─────────────────────────────────

stations <- fread("../example/tables/stations.csv")

cat("=== Table 1: Simple ===\n")
cat(render_typst(
  stations,
  columns = list(
    region = col("Region"),
    type = col("Type"),
    n_stations = col("Stations"),
    coverage_pct = col("Coverage (%)"),
    start_year = col("Start year")
  ),
  spanners = NULL, group_by = NULL, group_order = NULL,
  pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
  caption = "Monitoring station coverage by region and measurement type.",
  csv_dir = "/tmp/distiller-demo"
))
cat("\n\n")


# ── Table 2: Pivoted table ────────────────────────────────

anomalies <- fread("../example/tables/anomalies-by-region.csv")

cat("=== Table 2: Pivoted ===\n")
cat(render_typst(
  anomalies,
  columns = list(
    decade = col("Decade"),
    mean = col("Mean", fmt = "%.2f"),
    lower = col("Lower", fmt = "%.2f"),
    upper = col("Upper", fmt = "%.2f")
  ),
  spanners = NULL, group_by = NULL, group_order = NULL,
  pivot = "region",
  pivot_order = c("NH", "SH", "GL"),
  pivot_labels = list(NH = "Northern Hemisphere", SH = "Southern Hemisphere", GL = "Global"),
  caption = "Temperature anomalies by decade and region.",
  csv_dir = "/tmp/distiller-demo"
))
cat("\n\n")


# ── Table 3: Grouped row table ────────────────────────────

contributors <- fread("../example/tables/contributors.csv")

cat("=== Table 3: Grouped ===\n")
cat(render_typst(
  contributors,
  columns = list(
    source = col("Source"),
    region = col("Region"),
    type = col("Type"),
    n_stations = col("Stations"),
    quality_score = col("Quality")
  ),
  spanners = NULL,
  group_by = c("source", "region"),
  group_order = list(
    source = c("NOAA", "Met Office", "JMA"),
    region = c("NH", "SH")
  ),
  pivot = NULL, pivot_order = NULL, pivot_labels = NULL,
  caption = "Contributing data sources by region.",
  csv_dir = "/tmp/distiller-demo"
))
cat("\n\n")
