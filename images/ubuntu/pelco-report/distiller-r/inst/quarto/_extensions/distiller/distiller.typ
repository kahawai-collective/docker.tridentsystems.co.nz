// distiller — Data-driven tables and inline values for reproducible research
//
// Provides: fmt, value, records, register-format, distiller-table,
//           ci, mci, gloss, acr, cap, num, date, sy,
//           distiller-format, distiller-style,
//           qty, qtyrange, unit (re-exported from @preview/unify)

// Re-export the unit-formatting helpers from `unify` so distiller users
// have a single import for both data-driven values and siunitx-style
// quantities. unify's own `num` is shadowed by distiller's `num` (which
// has different ergonomics — thousands separators, NA handling, etc.).
// If you need unify's `num` directly, import the package yourself.
//
//   #qty("10", "m")          → "10 m"
//   #qty("123", "t/ha")      → "123 t ha⁻¹"
//   #qtyrange("10", "20", "m") → "(10–20) m"
//   #unit("ha^-1")           → "ha⁻¹"
//   #register-unit("stem", "stems", "stems") — register a new unit
#import "@preview/unify:0.8.0": qty, qtyrange, unit, add-unit, add-prefix

/// Register a new unit with a plain-text symbol. Wrapper around
/// unify's `add-unit` that auto-wraps the symbol in `upright(...)`
/// so it typesets as text rather than a math identifier — covers the
/// common case where the symbol is a literal abbreviation (e.g.
/// "stems", "pt") rather than a math expression.
///
///   #register-unit("stem", "stems", "stems")
///   #qty("498.9", "stems/ha") // → "498.9 stems ha⁻¹"
#let register-unit(name, shorthand, symbol, space: true) = {
  add-unit(name, shorthand, "upright(\"" + symbol + "\")", space: space)
}

/// Build a single-argument shortcut that applies a fixed unit to a value
/// via `qty`. The value may be a number or a string; it is coerced to a
/// string before formatting. Handy for defining project-specific unit
/// helpers once and calling them inline.
///
///   #let m2  = unit-fn("m2")        #m2(3)        // → "3 m²"
///   #let tha = unit-fn("t/ha")      #tha(123)     // → "123 t ha⁻¹"
#let unit-fn(u) = value => qty(if type(value) == str { value } else { str(value) }, u)

// ---------------------------------------------------------------------------
// Table style defaults
// ---------------------------------------------------------------------------

/// Default table styling options. All lengths are relative to the table
/// font size (em) unless noted. Override by passing a style dictionary
/// to distiller-table, or by redefining distiller-style.
///
/// Usage:
///   // Use defaults
///   #distiller-table(csv("data.csv"), columns: (...))
///
///   // Override for one table
///   #distiller-table(csv("data.csv"), columns: (...),
///     style: (font-size: 8pt, gutter: 1.2em))
///
///   // Override globally
///   #let distiller-style = (font-size: 8pt, gutter: 1.2em)
/// Hierarchical theme dictionary, inspired by ggplot2's `theme()` and
/// `element_*()` model. There are two element types — *text* and *rule* —
/// each with a default block and element-specific overrides. Properties
/// declared at the element level inherit from the default block; a key
/// set on an element overrides only that key.
///
/// Inheritance graph:
///
///     text → {header, subhead, data}.text
///     rule → {cmidrule, top-rule, header-rule, bottom-rule}
///
/// An element's value of `none` disables it (e.g. `top-rule: none`).
/// `(:)` enables it with all properties inherited. `auto` on a leaf
/// property means "inherit from the surrounding document" (e.g. fonts).
///
/// Override globally:
///   #let distiller-style = (..distiller-style,
///     text: (..distiller-style.text, family: "IBM Plex Sans"),
///     header: (text: (weight: "bold")),
///   )
///
/// Override one table:
///   distiller-table(data, style: (top-rule: (stroke: 0.6pt)), ...)
#let distiller-style = (
  // ── Spacing & sizing (flat — each controls a distinct thing) ─────
  font-size:    1em,    // table font size relative to document font
  gutter:       1em,    // column gutter
  row-inset:    0.3em,  // vertical padding in data cells
  rule-inset:   0.25em, // vertical padding around cmidrules
  header-space: 0.2em,  // addlinespace after the header
  group-space:  0.25em, // addlinespace between row groups

  // ── Text elements ────────────────────────────────────────────────
  // `text` is the default for every cell. Element dicts override.
  text: (
    family: auto,   // font family
    color:  auto,   // text colour
    weight: auto,   // weight ("regular", "semibold", "bold", a number…)
  ),
  header:  (text: (weight: "semibold")),  // column-label AND spanner row
  subhead: (text: (:)),                   // row-group labels (group-label)
  data:    (text: (:)),                   // data cells

  // ── Rule elements ────────────────────────────────────────────────
  // `rule` is the default for every horizontal rule (stroke + colour).
  // Each rule element overrides individual keys, or sets `none` to
  // disable. Stroke values can be Typst lengths; the renderer combines
  // them with `color` at render time.
  rule:        (stroke: 0.4pt, color: black),
  cmidrule:    (:),     // under spanners; enabled by default
  top-rule:    none,    // above the header (off by default — booktabs)
  header-rule: none,    // between header and body
  bottom-rule: none,    // below the last data row

  // ── Other ────────────────────────────────────────────────────────
  row-stripe:   none,  // alternating data-row fill (a colour) or `none`
  tabular-nums: true,  // OpenType `tnum` feature — fixed-width digits
                       // so columns of numbers align cleanly. Disable
                       // only for fonts that don't have the feature.
)

// ── Style resolvers ───────────────────────────────────────────────
// Walks the inheritance graph: element-specific dict over the default
// block (`text` / `rule`). `_resolve-text` returns a merged dict;
// `_resolve-rule` returns a typst stroke value (or `none` if disabled).
#let _resolve-text(style, element) = {
  let base = style.at("text", default: (:))
  let override = style.at(element, default: (:)).at("text", default: (:))
  base + override
}
#let _resolve-rule(style, key) = {
  let cfg = style.at(key, default: none)
  if cfg == none { return none }
  let base = style.at("rule", default: (:))
  let merged = base + cfg
  // Combine length + colour into a single stroke value.
  let stroke = merged.at("stroke", default: 0.4pt)
  let color  = merged.at("color",  default: black)
  stroke + color
}

// ---------------------------------------------------------------------------
// NA-safe predicates
// ---------------------------------------------------------------------------
// Helpers for writing `filter:` closures over records where some cells
// may be `none` (records() turns CSV "" and "NA" into `none`). Typst
// panics if you compare `none` to a number, so these guards keep
// filter expressions short and readable:
//
//   filter: r => r.events_tot > 1000 or
//     ("seabirds", "dffur").any(c => positive(r.at(c)))

// NA-safe presence: also treats the literal string "NA" as absent (the
// same convention records() applies on load).
#let present(v)  = v != none and v != "" and not (type(v) == str and v.trim() == "NA")
#let positive(v) = present(v) and float(v) > 0
#let negative(v) = present(v) and float(v) < 0
#let nonzero(v)  = present(v) and float(v) != 0

// ---------------------------------------------------------------------------
// Internal state
// ---------------------------------------------------------------------------

// Table context: true inside distiller-table, false in running text.
#let _distiller-ctx = state("distiller-ctx", false)

// State for cap() first-letter tracking
#let _cap-done = state("distiller-cap", false)

// Acronym first-use tracker
#let _acronym-state = state("acronyms-used", ())

// ---------------------------------------------------------------------------
// Internal number formatter
// ---------------------------------------------------------------------------

// Banker's rounding (half-to-even): rounds exact halves to the nearest
// even integer. Matches R's round() and Python's round(), and is the
// IEEE 754 default. Used when `round: "half-even"` is requested; the
// default in num() remains "half-up" (typst's calc.round behaviour, i.e.
// half-away-from-zero) for backward compatibility.
#let _round-half-even(x) = {
  let neg = x < 0
  let abs-x = if neg { -x } else { x }
  let floor-x = calc.floor(abs-x)
  let frac = abs-x - floor-x
  // Tolerance for FP comparison: exact halves like 0.5, 2.5, 0.25*10
  // are representable, but e.g. 0.15*10 = 1.4999... — those should
  // round down anyway, so a strict == 0.5 check is correct here.
  let result = if frac < 0.5 {
    floor-x
  } else if frac > 0.5 {
    floor-x + 1
  } else if calc.rem(floor-x, 2) == 0 {
    floor-x
  } else {
    floor-x + 1
  }
  if neg { -result } else { result }
}

/// Format a number with thousands separators and decimal places.
/// Returns a string. For most uses, prefer fmt() which is context-aware
/// and type-dispatched. Use num() when you need a string return value
/// or explicit control over the separator threshold.
///
/// `round:` controls the half-rounding rule.
///   - "half-up"   (default) — typst's calc.round: half-away-from-zero.
///   - "half-even" (banker's) — matches R / Python / IEEE 754 default.
#let num(value, dp: 0, threshold: 5, round: "half-up") = {
  if value == none { return [] }
  if type(value) == str and (value == "NA" or value.trim() == "") { return [] }
  let n = float(value)
  let factor = calc.pow(10, dp)
  let scaled = n * factor
  let rounded-int = if round == "half-even" {
    _round-half-even(scaled)
  } else {
    calc.round(scaled)
  }
  let rounded = rounded-int / factor

  let is-negative = rounded < 0
  let abs-val = calc.abs(rounded)
  let int-part = int(abs-val)
  let frac-str = if dp > 0 {
    let remainder = calc.round((abs-val - int-part) * factor)
    let s = str(int(remainder))
    while s.len() < dp { s = "0" + s }
    "." + s
  } else { "" }

  let sep = "\u{202F}"
  let int-str = str(int-part)
  let formatted = if int-str.len() >= threshold {
    let chars = int-str.clusters()
    let result = ()
    let count = chars.len()
    for (i, c) in chars.enumerate() {
      result.push(c)
      let remaining = count - i - 1
      if remaining > 0 and calc.rem(remaining, 3) == 0 {
        result.push(sep)
      }
    }
    result.join()
  } else {
    int-str
  }

  let prefix = if is-negative { "−" } else { "" }
  prefix + formatted + frac-str
}

// Internal split-year implementation (registered as "sy" kind below)
#let _sy-impl(value) = {
  let s = str(value).trim()
  let pad2(n) = {
    let d = calc.rem(n, 100)
    if d < 10 { "0" + str(d) } else { str(d) }
  }
  let parts = none
  for sep in ("/", "–", "-") {
    if s.contains(sep) {
      parts = s.split(sep)
      break
    }
  }
  if parts != none {
    let first = int(parts.at(0))
    str(first) + "–" + pad2(first + 1)
  } else {
    let second = int(s)
    str(second - 1) + "–" + pad2(second)
  }
}

// ---------------------------------------------------------------------------
// Format registry — type-aware defaults for fmt()
// ---------------------------------------------------------------------------

/// Default formatting rules per type. Each kind maps to a format spec.
/// Built-in kinds use declarative specs or fmt: functions.
/// User-defined kinds provide a fmt: function via register-format().
///
///   // Override globally
///   #let distiller-format = (..distiller-format, float: (dp: 1))
#let distiller-format = (
  int:   (dp: 0),
  float: (dp: 2),
  pct:   (dp: 1, suffix: [%]),
  // fraction — value is in [0, 1] and renders as a percentage. Same
  // table/text suffix behaviour as `pct` (suffix dropped in tables —
  // it belongs in the column header). Use when the source data is a
  // proportion (e.g. `0.785`) rather than already-scaled (78.5).
  fraction: (dp: 1, suffix: [%], scale: 100),
  // markup — value is a string of Typst markup that should be
  // evaluated (not rendered literally). Useful for tables loaded from
  // parse-csv / parse-table raw blocks where cells naturally contain
  // `#emph[...]`, raw `` `code` `` spans, and citations like `@key`.
  // Non-string values pass through unchanged.
  markup: (fmt: v => if type(v) == str { eval(v, mode: "markup") } else { v }),
  date:  (fmt: (value, display: "[day padding:none] [month repr:long] [year]") => {
    let dt = if type(value) == str {
      let parts = value.split("-")
      datetime(year: int(parts.at(0)), month: int(parts.at(1)), day: int(parts.at(2)))
    } else { value }
    dt.display(display)
  }),
  sy:    (fmt: value => _sy-impl(value)),
  ci:    (fmt: (record, dp: 0) => {
    context {
      let threshold = if _distiller-ctx.get() { 4 } else { 5 }
      (
        num(float(record.at("lower")), dp: dp, threshold: threshold)
          + "\u{2060}–\u{2060}"
          + num(float(record.at("upper")), dp: dp, threshold: threshold)
      )
    }
  }),
  mci:   (fmt: (record, dp: 0, label: [95% c.i.]) => {
    context {
      let threshold = if _distiller-ctx.get() { 4 } else { 5 }
      let m = num(float(record.at("mean")), dp: dp, threshold: threshold)
      let l = num(float(record.at("lower")), dp: dp, threshold: threshold)
      let u = num(float(record.at("upper")), dp: dp, threshold: threshold)
      [#m (#label: #l\u{2060}–\u{2060}#u)]
    }
  }),
  // qty — a number together with a unit. Pass `unit: "m"` (or any
  // unify-style unit string such as "t/ha", "m^3/ha/yr"). Wraps
  // unify's qty(); the value is first formatted with distiller's
  // own num() so thousands separators and dp behave consistently.
  //
  // Inline:   #fmt(10,  kind: "qty", unit: "m")        → "10 m"
  //           #fmt(123, kind: "qty", unit: "t/ha")     → "123 t ha⁻¹"
  // In tables:
  //   columns: (
  //     height: (label: [Height], kind: "qty", unit: "m"),
  //     rate:   (label: [Rate],   kind: "qty", unit: "t/ha", dp: 1),
  //   )
  qty:   (fmt: (value, unit: none, dp: 0) => {
    assert(unit != none, message: "fmt(kind: \"qty\") requires a `unit:` argument")
    context {
      let threshold = if _distiller-ctx.get() { 4 } else { 5 }
      let formatted = num(float(value), dp: dp, threshold: threshold)
      qty(formatted, unit)
    }
  }),
  bool:  (:),
  str:   (:),
)

// Format registry state — allows user extensions via register-format()
#let _distiller-fmt = state("distiller-fmt", distiller-format)

// ---------------------------------------------------------------------------
// fmt — universal type-dispatched formatter
// ---------------------------------------------------------------------------

/// Format any value for display. Dispatches on the value's type, using
/// the distiller-format registry for defaults.
///
/// In running text, fmt auto-detects the type from the value:
///   #fmt(423)                    // int → "423"
///   #fmt(78.2)                   // float → "78.20"
///   #fmt(datetime(2024, 1, 15))  // date → "15 January 2024"
///   #fmt(true)                   // bool → "Yes"
///
/// Use `kind:` for types that can't be auto-detected:
///   #fmt(78.2, kind: "pct")        // → "78.2%"
///   #fmt(2009, kind: "sy")         // → "2008–09"
///
/// Override decimal places:
///   #fmt(78.2, dp: 1)            // → "78.2" (overrides float default of 2)
///
/// Inside distiller-table, the thousands-separator threshold adjusts
/// automatically (4+ digits vs 5+ in text). No table: parameter needed.
///
/// In tables, the column type: field provides the `kind:` dispatch:
///   columns: (
///     rate: (label: [Rate], kind: "pct"),
///     year: (label: [Year], kind: "sy"),
///   )
/// Register a custom type in the format registry.
///
///   #register-format("species", gloss(json("data/labels.json")))
///   #register-format("fishing-year", value => sy(value))
///   #register-format("pct", (dp: 2, suffix: [%]))  // override built-in defaults
///
/// The second argument can be:
///   - A function: registered as the type's fmt function
///   - A dictionary: merged as the type's format spec
#let register-format(name, spec) = {
  _distiller-fmt.update(reg => {
    if type(spec) == function {
      reg.insert(name, (fmt: spec))
    } else {
      reg.insert(name, spec)
    }
    reg
  })
}

#let fmt(..args) = {
  let pos = args.pos()
  let named = args.named()
  let kind-override = named.at("kind", default: auto)
  let dp-override = named.at("dp", default: auto)
  let ctx-override = named.at("context", default: auto)

  // Collect extra named args to forward to format functions
  let extra = (:)
  for (k, v) in named {
    if k != "kind" and k != "dp" and k != "context" {
      extra.insert(k, v)
    }
  }

  // ── Determine the value and kind based on calling convention ──
  let the-value = none
  let the-kind = kind-override

  if pos.len() == 0 {
    // fmt(lower: 5, upper: 8, kind: "ci") — named args as record
    the-value = extra
    extra = (:)
  } else if pos.len() == 1 {
    let arg = pos.at(0)
    if type(arg) == dictionary and "_kinds" in arg {
      let data-keys = arg.keys().filter(k => k != "_kinds")
      if data-keys.len() == 1 {
        // fmt(single-field-record) — extract the one data field. A
        // `kind:` override (e.g. fmt(cell(...), kind: "fraction"))
        // overrides the sidecar kind; otherwise the sidecar wins.
        let field = data-keys.at(0)
        the-value = arg.at(field)
        if the-kind == auto { the-kind = arg._kinds.at(field, default: auto) }
      } else if kind-override != auto {
        // fmt(row, kind: "ci") — compound kind, whole multi-field record
        the-value = arg
      } else {
        // Multi-field record without field name or kind — can't format
        the-value = arg
      }
    } else {
      // fmt(plain-value) — auto-detect
      the-value = arg
    }
  } else if pos.len() == 2 {
    let arg1 = pos.at(0)
    let arg2 = pos.at(1)
    if type(arg1) == dictionary and "_kinds" in arg1 and type(arg2) == str {
      // fmt(row, "field") — extract field, kind from sidecar
      the-value = arg1.at(arg2)
      if the-kind == auto { the-kind = arg1._kinds.at(arg2, default: auto) }
    } else {
      // Fallback: treat first as value
      the-value = arg1
    }
  }

  // Handle none / NA
  if the-value == none { return [] }
  if type(the-value) == str and (the-value == "NA" or the-value.trim() == "") { return [] }

  // ── Resolve kind ──
  let type-name = if the-kind != auto { the-kind }
    else if type(the-value) == int { "int" }
    else if type(the-value) == float { "float" }
    else if type(the-value) == datetime { "date" }
    else if type(the-value) == bool { "bool" }
    else { "str" }

  // ── Dispatch ──
  context {
    let in-table = if ctx-override != auto { ctx-override == "table" }
      else { _distiller-ctx.get() }
    let threshold = if in-table { 4 } else { 5 }
    let registry = _distiller-fmt.get()
    let spec = registry.at(type-name, default: (:))

    // User-defined type with fmt: function
    if "fmt" in spec {
      let fn = spec.fmt
      if dp-override != auto {
        return (fn)(the-value, dp: dp-override, ..extra)
      } else if extra.len() > 0 {
        return (fn)(the-value, ..extra)
      } else {
        return (fn)(the-value)
      }
    }

    // Built-in dispatch
    let round-mode = extra.at("round", default: spec.at("round", default: "half-up"))
    if type-name == "int" or type-name == "float" {
      let d = if dp-override != auto { dp-override } else { spec.at("dp", default: 0) }
      num(the-value, dp: d, threshold: threshold, round: round-mode)
    } else if type-name == "pct" or type-name == "fraction" {
      let d = if dp-override != auto { dp-override } else { spec.at("dp", default: 1) }
      let suffix = spec.at("suffix", default: [%])
      // `scale` lets one branch serve both kinds: `pct` is already a
      // percentage (scale 1); `fraction` is a proportion in [0, 1]
      // (scale 100). The display rule is otherwise identical.
      let scale = spec.at("scale", default: 1)
      let scaled = float(the-value) * scale
      // In tables, suppress the suffix — it belongs in the column header
      if in-table {
        num(scaled, dp: d, threshold: threshold, round: round-mode)
      } else {
        num(scaled, dp: d, threshold: threshold, round: round-mode) + suffix
      }
    } else if type-name == "bool" {
      if the-value { [Yes] } else { [No] }
    } else if kind-override != auto and type-name not in ("int", "float", "pct", "fraction", "bool", "str", "date", "sy", "ci", "mci", "qty") {
      // Unknown explicit kind — treat as a unit string. So
      // `fmt(10, kind: "m")` is shorthand for
      // `fmt(10, kind: "qty", unit: "m")`. Any unify-style unit
      // string works: "m", "t/ha", "m^3/ha/yr", "ha^-1".
      let d = if dp-override != auto { dp-override } else { spec.at("dp", default: 0) }
      qty(num(float(the-value), dp: d, threshold: threshold, round: round-mode), type-name)
    } else if type(the-value) == dictionary {
      // Compound kind with dict value — pass through to format function
      repr(the-value)
    } else {
      the-value
    }
  }
}

// ---------------------------------------------------------------------------
// Convenience wrappers — thin functions around fmt()
// ---------------------------------------------------------------------------

/// Format a split year: #sy(2009) → "2008–09"
#let sy(value) = fmt(value, kind: "sy")

/// Format a confidence interval: #ci(85, 168) → "85–168"
#let ci(lower, upper, dp: auto) = {
  if dp != auto {
    fmt((lower: float(lower), upper: float(upper)), kind: "ci", dp: dp)
  } else {
    fmt((lower: float(lower), upper: float(upper)), kind: "ci")
  }
}

/// Format mean with credible interval: #mci(124, 85, 168) → "124 (95% c.i.: 85–168)"
#let mci(mean, lower, upper, dp: auto, label: [95% c.i.]) = {
  if dp != auto {
    fmt((mean: float(mean), lower: float(lower), upper: float(upper)), kind: "mci", dp: dp, label: label)
  } else {
    fmt((mean: float(mean), lower: float(lower), upper: float(upper)), kind: "mci", label: label)
  }
}

/// Parse an ISO date string and format: #date("2024-01-15") → "15 January 2024"
#let date(s, display: "[day padding:none] [month repr:long] [year]") = {
  fmt(s, kind: "date", display: display)
}

// ---------------------------------------------------------------------------
// Type factories
// ---------------------------------------------------------------------------

/// Coerce a variety of lookup-style inputs into a flat `key → value`
/// dictionary. Used internally by `gloss` and `acr` so any of these
/// shapes feed the same lookup API:
///
///   - A plain dictionary (the canonical form). Returned as-is.
///   - A 2D array from `csv(...)`:
///       * 1 data row → columns become keys (e.g. fit-summary CSVs).
///       * Otherwise → first column is the key, second is the value
///         (e.g. a 2-column glossary CSV).
///   - An array of dicts from `records(...)` or a JSON list:
///       * 1 record → fields of that record become keys.
///       * Otherwise → first two fields are key, value.
///
/// Examples:
///   labels.json   {"AGB": "above-ground biomass", "FMA": "..."}
///   labels.csv    code,definition\nAGB,above-ground biomass\n...
///   fit-sum.csv   n_train,rhat_max\n170565,1.02
///
/// All three load into the same shape: a `(key → value)` dict that
/// `gloss(...)` wraps in a lookup function.
#let _as-lookup-dict(input) = {
  if type(input) == dictionary { return input }
  if type(input) != array or input.len() == 0 { return (:) }
  let first = input.at(0)

  // 2D array path (csv(...)): first row is headers, the rest are
  // data rows. csv() yields strings; cast numeric-looking strings to
  // float/int so `gloss(csv("fit-summary.csv"))("rhat_max")` yields a
  // number rather than the literal "1.0169" string.
  let _cast(v) = {
    if type(v) != str { return v }
    let trimmed = v.trim()
    if trimmed == "" or trimmed == "NA" { return none }
    if trimmed.match(regex("^-?\d+$")) != none { return int(trimmed) }
    if trimmed.match(regex("^-?\d+\.\d+$")) != none { return float(trimmed) }
    v
  }
  if type(first) == array {
    let headers = first
    let data = input.slice(1)
    let out = (:)
    if data.len() == 1 {
      let row = data.at(0)
      for (i, h) in headers.enumerate() { out.insert(str(h), _cast(row.at(i))) }
      return out
    }
    assert(headers.len() >= 2,
      message: "gloss: need at least 2 columns for key/value lookup")
    for row in data { out.insert(str(row.at(0)), _cast(row.at(1))) }
    return out
  }

  // Array of dicts (records() or JSON list).
  if type(first) == dictionary {
    let cols = first.keys().filter(k => k != "_kinds")
    let out = (:)
    if input.len() == 1 {
      // Single-record: each field → its value.
      for c in cols { out.insert(c, first.at(c)) }
      return out
    }
    // Multi-record: first column is key, second is value.
    assert(cols.len() >= 2,
      message: "gloss: array of records needs at least 2 columns for key/value lookup")
    let key-col = cols.at(0)
    let val-col = cols.at(1)
    for r in input { out.insert(str(r.at(key-col)), r.at(val-col)) }
    return out
  }

  panic("gloss/acr: unsupported input type " + str(type(input)))
}

/// Create a label lookup formatter.
///
/// `gloss` is *always-expand*: every call returns the full expansion
/// regardless of how often the code has been seen. Use it as a column
/// formatter for table cells, or anywhere you want unambiguous
/// expansion. For prose first-mentions, see `acr` below — same data,
/// different semantics.
///
/// Accepts any of:
///   - A flat dictionary `{code: expansion, ...}`.
///   - A 2-column CSV via `csv(...)` — rows are key/value pairs.
///   - A single-row CSV via `csv(...)` — each column is a key (good
///     for fit-summary tables where you want `s("n_train")` etc.).
///   - A JSON file via `json(...)` (dict or list of records).
///   - Pre-loaded `records(...)` output.
///
///   #let g = gloss(json("data/labels.json"))
///   #g("WCA")          // → "white-capped albatross"  (every time)
///   #cap(g("WCA"))     // → "White-capped albatross"
///
///   #let stats = gloss(csv("path/to/fit-summary.csv"))
///   #stats("n_train")  // → "170565"
///
///   // As column formatter
///   taxon: (label: [Species], fmt: g)
///
///   // Or register as a kind
///   #let distiller-format = (..distiller-format, species: (fmt: g))
///   taxon: (label: [Species], kind: "species")
#let gloss(labels) = {
  let dict = _as-lookup-dict(labels)
  code => {
    if str(code) in dict { dict.at(str(code)) } else { code }
  }
}

/// Create an acronym tracker formatter.
///
/// `acr` is *first-use-expand*: the first call for a given code in
/// the document returns `"expansion (CODE)"`; subsequent calls return
/// just `CODE`. State is tracked per-tracker instance, document-wide.
/// Use it for prose mentions so that a reader meets each acronym in
/// its expanded form on first contact, with bare codes thereafter.
///
/// `gloss` and `acr` accept the same `code → expansion` dictionary,
/// so the same data file can drive both:
///
///   #let labels = json("data/labels.json")
///   #let g = gloss(labels)   // table cells: full name every time
///   #let a = acr(labels)     // prose: expand on first use only
///
/// Usage:
///   #let a = acr(json("data/labels.json"))
///   #a("ETS")  // → "emissions trading scheme (ETS)" (first use)
///   #a("ETS")  // → "ETS" (subsequent uses)
#let acr(labels) = {
  let dict = _as-lookup-dict(labels)
  code => {
    context {
      let used = _acronym-state.get()
      let key = str(code)
      if key not in used {
        _acronym-state.update(u => {
          u.push(key)
          u
        })
        let expansion = if key in dict { dict.at(key) } else { code }
        [#expansion (#code)]
      } else {
        code
      }
    }
  }
}

// ---------------------------------------------------------------------------
// String transforms
// ---------------------------------------------------------------------------

/// Upper-case the first letter of a string or content.
/// Works with both plain strings and content (including fmt() output).
/// Sits alongside #upper and #lower as a general-purpose text transform.
#let cap(body) = {
  if type(body) == str {
    if body.len() == 0 { return body }
    upper(body.first()) + body.slice(1)
  } else {
    // Content path: use a show rule with state to capitalise
    // only the first letter character
    _cap-done.update(false)
    show regex("[a-zA-Z]"): it => {
      context {
        if not _cap-done.get() {
          _cap-done.update(true)
          upper(it)
        } else {
          it
        }
      }
    }
    body
  }
}

// ---------------------------------------------------------------------------
// Inline table parsing
// ---------------------------------------------------------------------------

/// Parse a markdown-style pipe table from raw text. Returns a 2D array
/// (header row + data rows) — same shape as `csv()` — so the result
/// composes with `records()` and `distiller-table` exactly like a file.
///
/// Recognises:
///   - `|` as the column separator (leading and trailing `|` optional)
///   - Whitespace around each cell is trimmed
///   - Markdown alignment / separator rows (`|---|---|`, `|:---:|---:|`)
///     are skipped automatically
///   - Blank lines are skipped
///
/// Typical use is with a Typst raw block:
///
///   #let data = ```
///   | Region    | Stand | Year |
///   |-----------|-------|------|
///   | Southland | 44-01 | 2004 |
///   | Nelson    | 1-08  | 2015 |
///   ```
///   #distiller-table(parse-table(data.text), columns: ( ... ))
///
/// The raw block keeps the data visually aligned in the source file
/// (most editors auto-format pipe tables) so cells are easy to edit
/// without disturbing alignment.
#let parse-table(text) = {
  let sep-pat = regex("^[:\\-\\s]+$")
  let rows = ()
  for raw-line in text.split("\n") {
    let line = raw-line.trim()
    if line == "" { continue }
    if line.starts-with("|") { line = line.slice(1) }
    if line.ends-with("|") { line = line.slice(0, line.len() - 1) }
    let cells = line.split("|").map(c => c.trim())
    // Skip markdown separator rows where every cell matches `---` / `:---:` /
    // `---:` / `:---`.
    if cells.all(c => c != "" and c.match(sep-pat) != none) { continue }
    rows.push(cells)
  }
  rows
}

/// Parse inline CSV text from a raw block. Returns a 2D array (header
/// row + data rows) — the same shape `csv()` returns — so the result
/// composes with `records()` and `distiller-table` exactly like a file
/// load.
///
/// Recognises:
///   - `,` as the column separator
///   - newline as the row separator
///   - `"..."` quoting for cells that contain commas, newlines, or
///     embedded quotes (`""` inside a quoted cell becomes a single `"`)
///   - whitespace around unquoted cells is trimmed
///   - blank lines are skipped
///   - CRLF and LF line endings both accepted
///
/// Typical use is with a Typst raw block:
///
///   #let data = ```
///   Region,Stand,Year
///   Southland,44-01,2004
///   Nelson,1-08,2015
///   ```
///   #distiller-table(parse-csv(data.text), columns: ( ... ))
///
/// Use `"..."` to quote cells that contain commas — e.g.
/// `"Squid (SQU), Hoki (HOK)"`.
#let parse-csv(text) = {
  // Normalise line endings up front: a CRLF is one grapheme cluster in
  // Unicode, which would slip past per-character checks below.
  let text = text.replace("\r\n", "\n").replace("\r", "\n")
  let chars = text.clusters()
  let n = chars.len()
  let rows = ()
  let row = ()
  let cell = ""
  let cell-was-quoted = false
  let in-quote = false
  let i = 0
  while i < n {
    let c = chars.at(i)
    if in-quote {
      if c == "\"" {
        if i + 1 < n and chars.at(i + 1) == "\"" {
          // Escaped quote inside a quoted cell.
          cell = cell + "\""
          i += 2
        } else {
          in-quote = false
          i += 1
        }
      } else {
        cell = cell + c
        i += 1
      }
    } else if c == "\"" and cell.trim() == "" {
      // Start of a quoted cell (discard any leading whitespace).
      in-quote = true
      cell-was-quoted = true
      cell = ""
      i += 1
    } else if c == "," {
      row.push(if cell-was-quoted { cell } else { cell.trim() })
      cell = ""
      cell-was-quoted = false
      i += 1
    } else if c == "\n" {
      row.push(if cell-was-quoted { cell } else { cell.trim() })
      if row.any(v => v != "") { rows.push(row) }
      row = ()
      cell = ""
      cell-was-quoted = false
      i += 1
    } else if c == "\r" {
      i += 1
    } else {
      cell = cell + c
      i += 1
    }
  }
  // Flush any trailing cell / row that didn't end with a newline.
  if cell != "" or row.len() > 0 {
    row.push(if cell-was-quoted { cell } else { cell.trim() })
    if row.any(v => v != "") { rows.push(row) }
  }
  rows
}

// ---------------------------------------------------------------------------
// Data lookup
// ---------------------------------------------------------------------------

// Build a sort key function from an `order-by` spec.
//   function          → used as-is
//   string            → ascending by that column
//   array of strings  → ascending by each; `-` prefix on a string means
//                       descending (numeric columns only)
#let _order-by-key(spec) = {
  if type(spec) == function { return spec }
  if type(spec) == str {
    let col = spec
    return rec => rec.at(col)
  }
  if type(spec) == array {
    return rec => spec.map(s => {
      let desc = s.starts-with("-")
      let col = if desc { s.slice(1) } else { s }
      let v = rec.at(col)
      if not desc { v } else if type(v) == int or type(v) == float { -v }
      else {
        panic(
          "order-by \"-" + col + "\": descending sort is only supported on "
          + "numeric columns; pass a closure for non-numeric descending."
        )
      }
    })
  }
  panic("order-by must be a function, string, or array of strings")
}

/// Convert data to an array of dictionaries with auto-detected types.
///
/// Accepts:
///   - 2D array from csv() or inline Typst arrays (first row = headers)
///   - Array of dictionaries from json()
///
/// Like data.table's fread(), types are auto-detected per column:
///   - Columns where all non-empty values are numeric → int/float
///   - Empty strings and "NA" → none
///   - Everything else stays as-is
///
/// Use the types parameter to override auto-detection per column:
///   - `"str"` — keep as string (useful for years, IDs, zip codes)
///   - `"int"` — force integer
///   - `"float"` — force float
///
/// `filter` and `order-by` apply after typing, so closures can rely on
/// `int`/`float` cells being numbers (no `float(r.x)` needed):
///
///   records(csv("..."),
///     filter:   r => r.events_tot > 1000,
///     order-by: ("region", "-events_tot"),  // R-style; `-` = descending
///   )
///
/// `order-by` accepts:
///   - a closure `r => key`     — full flexibility (use for custom factor orders)
///   - a string `"col"`         — ascending by one column
///   - an array of strings      — ascending by each; `-col` for descending
///                                (numeric columns only)
///
///   #let data = records(csv("tables/data.csv"))
///   #let data = records(json("tables/data.json"))
///   #let data = records(csv("data.csv"), types: (year: "str", id: "str"))
#let records(raw, types: (:), kinds: (:), filter: none, order-by: none) = {
  // Apply filter and ordering after typing. Factored so all early-return
  // paths share the same post-processing.
  let _post(recs) = {
    let r = if filter != none { recs.filter(filter) } else { recs }
    if order-by != none { r.sorted(key: _order-by-key(order-by)) } else { r }
  }
  let recs = if type(raw) == dictionary and "_kinds" not in raw {
    // Single JSON object — wrap as a one-row dataset
    (raw,)
  } else if type(raw) == array and raw.len() > 0 and type(raw.at(0)) == dictionary {
    raw
  } else {
    let headers = raw.at(0)
    let result = ()
    for row in raw.slice(1) {
      let record = (:)
      for (i, h) in headers.enumerate() {
        record.insert(h, row.at(i))
      }
      result.push(record)
    }
    result
  }

  if recs.len() == 0 { return _post(recs) }

  // If data already has _kinds sidecar and no overrides requested,
  // return as-is (avoids re-processing already-typed records)
  let has-sidecar = "_kinds" in recs.at(0)
  if has-sidecar and types.len() == 0 and kinds.len() == 0 {
    return _post(recs)
  }
  // If data has sidecar, preserve existing kinds as defaults
  let existing-kinds = if has-sidecar { recs.at(0).at("_kinds") } else { (:) }

  // Auto-detect column types
  let all-cols = recs.at(0).keys().filter(k => k != "_kinds")
  let num-pattern = regex("^-?\\d+\\.?\\d*$")
  let int-pattern = regex("^-?\\d+$")
  let col-types = (:)

  for col in all-cols {
    if col in types {
      col-types.insert(col, types.at(col))
    } else {
      let is-num = recs.all(r => {
        let v = r.at(col)
        if type(v) == int or type(v) == float { true } else if type(v) == str {
          let trimmed = v.trim()
          if trimmed == "" or trimmed == "NA" { true } else { trimmed.match(num-pattern) != none }
        } else { false }
      })
      col-types.insert(col, if is-num { "num" } else { "str" })
    }
  }

  // Build the _kinds sidecar for each column
  // Priority: explicit kinds: > existing sidecar > auto-detect
  let col-kinds = (:)
  for col in all-cols {
    if col in kinds {
      // Explicit kind from kinds: parameter
      col-kinds.insert(col, kinds.at(col))
    } else if col in existing-kinds {
      // Preserve existing kind from sidecar
      col-kinds.insert(col, existing-kinds.at(col))
    } else {
      // Auto-detect kind from data type
      let ct = col-types.at(col, default: "str")
      if ct == "num" {
        // Determine int vs float from actual values
        let has-float = recs.any(r => {
          let v = r.at(col)
          if type(v) == float { true }
          else if type(v) == str {
            let trimmed = v.trim()
            trimmed != "" and trimmed != "NA" and trimmed.match(int-pattern) == none
          } else { false }
        })
        col-kinds.insert(col, if has-float { "float" } else { "int" })
      } else if ct == "int" { col-kinds.insert(col, "int") }
      else if ct == "float" { col-kinds.insert(col, "float") }
      else { col-kinds.insert(col, "str") }
    }
  }

  // Cast values and attach _kinds sidecar
  let typed = recs.map(r => {
    let new-r = (:)
    for (k, v) in r {
      if k == "_kinds" { continue }
      let target = col-types.at(k, default: "str")
      if v == none {
        new-r.insert(k, none)
      } else if type(v) == str {
        let trimmed = v.trim()
        if trimmed == "" or trimmed == "NA" {
          new-r.insert(k, none)
        } else if target == "num" {
          if trimmed.match(int-pattern) != none {
            new-r.insert(k, int(trimmed))
          } else {
            new-r.insert(k, float(trimmed))
          }
        } else if target == "int" {
          new-r.insert(k, int(float(trimmed)))
        } else if target == "float" {
          new-r.insert(k, float(trimmed))
        } else {
          new-r.insert(k, v)
        }
      } else if target == "str" and type(v) != str and type(v) != content {
        // Coerce numbers / booleans / etc. to string for str columns.
        // Content values (typst markup blocks) pass through unchanged
        // since str() doesn't accept them.
        new-r.insert(k, str(v))
      } else {
        new-r.insert(k, v)
      }
    }
    new-r.insert("_kinds", col-kinds)
    new-r
  })
  _post(typed)
}

/// Extract values from records. Supports row lookup (by key columns),
/// single-field extraction, and curried multi-key lookup.
///
/// Row lookup (returns full record with _kinds sidecar):
///   #let v = value(data, "species")
///   #let ri = v("WCA")
///   #fmt(ri, "mean")
///
/// Multi-key lookup (curried):
///   #let v = value(data, "species", "method")
///   #let wt = v("WCA", "Trawl")
///
/// Single-field extraction (returns single-field record):
///   #let temp = value(data, 0, "temperature")
///   #fmt(temp)
#let value(data, ..args) = {
  let pos = args.pos()

  // value(record-dict, "field") — single-field extraction from a record
  if type(data) == dictionary and "_kinds" in data and pos.len() >= 1 and type(pos.at(0)) == str {
    let field = pos.at(0)
    let kinds = data.at("_kinds", default: (:))
    let result = (:)
    result.insert(field, data.at(field))
    let field-kinds = (:)
    if field in kinds { field-kinds.insert(field, kinds.at(field)) }
    result.insert("_kinds", field-kinds)
    return result
  }

  // value(records-array, key-col, ...) — dataset lookup
  if type(data) == array {
    let key-cols = pos

    // If last positional arg is a field name that exists in the records
    // but is NOT a key column value, treat it as single-field extraction.
    // Heuristic: if all args are strings and the last one matches a column
    // in the first record, check if it's a data column (not a key value).
    // For single-field extraction, use value(data, row-index, "field")
    // where row-index is an integer.

    // value(data, int-index, "field") — single-field extraction by row index
    if pos.len() >= 2 and type(pos.at(0)) == int {
      let idx = pos.at(0)
      let field = pos.at(1)
      let record = data.at(idx)
      let kinds = record.at("_kinds", default: (:))
      let result = (:)
      result.insert(field, record.at(field))
      let field-kinds = (:)
      if field in kinds { field-kinds.insert(field, kinds.at(field)) }
      result.insert("_kinds", field-kinds)
      return result
    }

    // Multi-key lookup — return curried function or direct lookup
    assert(
      key-cols.len() >= 1 and key-cols.len() <= 3,
      message: "value: expected 1–3 key columns, got " + str(key-cols.len()),
    )

    if key-cols.len() == 1 {
      let k1 = key-cols.at(0)
      v1 => {
        let matches = data.filter(r => str(r.at(k1)) == str(v1))
        assert(matches.len() > 0, message: "value: no row where " + k1 + " = " + str(v1))
        matches.at(0)
      }
    } else if key-cols.len() == 2 {
      let k1 = key-cols.at(0)
      let k2 = key-cols.at(1)
      (v1, v2) => {
        let matches = data.filter(r => str(r.at(k1)) == str(v1) and str(r.at(k2)) == str(v2))
        assert(matches.len() > 0, message: "value: no row where " + k1 + " = " + str(v1) + " and " + k2 + " = " + str(v2))
        matches.at(0)
      }
    } else {
      let k1 = key-cols.at(0)
      let k2 = key-cols.at(1)
      let k3 = key-cols.at(2)
      (v1, v2, v3) => {
        let matches = data.filter(r => str(r.at(k1)) == str(v1) and str(r.at(k2)) == str(v2) and str(r.at(k3)) == str(v3))
        assert(
          matches.len() > 0,
          message: "value: no row where " + k1 + " = " + str(v1) + " and " + k2 + " = " + str(v2) + " and " + k3 + " = " + str(v3),
        )
        matches.at(0)
      }
    }
  } else {
    // value(plain-value, "field-name", kind: "...") — construct single-field record
    let field-name = if pos.len() > 0 { pos.at(0) } else { "value" }
    let k = args.named().at("kind", default: auto)
    let auto-kind = if type(data) == int { "int" }
      else if type(data) == float { "float" }
      else if type(data) == datetime { "date" }
      else if type(data) == bool { "bool" }
      else { "str" }
    let result = (:)
    result.insert(field-name, data)
    result.insert("_kinds", (:))
    result._kinds.insert(field-name, if k != auto { k } else { auto-kind })
    result
  }
}


/// Look up a single cell from records, carrying the column's kind.
///
/// Returns a single-field record `(value-col: v, _kinds: (value-col: kind))`
/// — the same shape `value(data, idx, field)` returns — so the kind
/// declared at import travels through to `fmt` without being re-stated:
///
///   #let acc = records(csv("accuracy.csv"), kinds: (rate: "fraction"))
///   #fmt(cell(acc, "group", "BIRDS", "rate"))   // → "85.6%"  (kind carried)
///
/// To recover the bare value, index the field: `cell(...).at("rate")`.
#let cell(records, key-col, key-val, value-col, filter-col: none, filter-val: none) = {
  let filtered = records
  if filter-col != none {
    filtered = filtered.filter(r => r.at(filter-col) == filter-val)
  }
  let matches = filtered.filter(r => r.at(key-col) == key-val)
  assert(matches.len() > 0, message: "cell: no row where " + key-col + " = " + key-val)
  let row = matches.at(0)
  let kinds = row.at("_kinds", default: (:))
  let result = (:)
  result.insert(value-col, row.at(value-col))
  let field-kinds = (:)
  if value-col in kinds { field-kinds.insert(value-col, kinds.at(value-col)) }
  result.insert("_kinds", field-kinds)
  result
}

/// Formatted key/value lookup — `gloss` plus `fmt`.
///
/// `gloss` already turns a 2-column (or single-row) CSV / JSON / records
/// table into a `key → value` lookup; `kv` layers automatic formatting
/// on top, so a long-format "metric,value" table drops a *formatted*
/// number into prose by name, with no `fmt(cell(...))` wrapper:
///
///   #let m = kv(csv("match-summary.csv"))
///   We linked #m("total_matches") captures.        // → "8022" → "8 022"
///
/// Declare per-key kinds once (the distiller principle — kind at the
/// boundary, not the call site); call-site named args override them and
/// are forwarded to `fmt`:
///
///   #let m = kv(csv("match-summary.csv"), kinds: (capture_rate: "fraction"))
///   #m("capture_rate")            // → "1.2%"
///   #m("mean_depth", kind: "m")   // → "120 m"  (call-site override)
///
/// Unknown keys return the key itself, matching `gloss`.
#let kv(data, kinds: (:)) = {
  let g = gloss(data)
  (key, ..opts) => {
    let named = (kind: kinds.at(str(key), default: auto)) + opts.named()
    fmt(g(key), ..named)
  }
}


/// Wrap a posterior-coefficients table in a curried lookup that
/// formats a chosen variable as `mean (95% c.i.: lower–upper)`.
///
/// The default column names (`variable`, `Estimate`, `Q2.5`, `Q97.5`)
/// match the convention used by `brms::posterior_summary()` and
/// related R tooling; override the named args for other layouts
/// (e.g. `lower: "q05", upper: "q95"` for 90% intervals).
///
/// Usage:
///   #let hsc = coefs(csv("path/to/coefficients.csv"))
///   The model uncertainty was #hsc("sigma", dp: 4).
///   Regenerated stands had a coefficient of
///     #hsc("b_establishmentRegenerated", dp: 2).
///   Maximum biomass was
///     #hsc("b_logAGBinf_Intercept", dp: 0, trans: calc.exp).
///
/// `data` should be a 2D array from `csv(...)` or an array of dicts;
/// `records(...)` is applied internally. Loading the CSV in the
/// caller's file (rather than passing a path) is required so Typst
/// resolves the path against your project, not the distiller package.
#let coefs(
  data,
  key:   "variable",
  mean:  "Estimate",
  lower: "Q2.5",
  upper: "Q97.5",
  label: [95% c.i.],
) = {
  let recs = records(data)
  let lookup = value(recs, key)
  (var, dp: 1, trans: none) => {
    let row = lookup(var)
    let xf = if trans == none { x => x } else { trans }
    mci(
      xf(float(row.at(mean))),
      xf(float(row.at(lower))),
      xf(float(row.at(upper))),
      dp: dp,
      label: label,
    )
  }
}


// ---------------------------------------------------------------------------
// distiller-table
// ---------------------------------------------------------------------------

/// Build a data-driven table from CSV, JSON, or inline data.
///
/// Parameters:
///   - data: table data in any of these formats:
///       - 2D array from csv() or inline Typst arrays (first row is headers)
///       - array of dictionaries from json() or records()
///   - columns: dictionary mapping data column names to display definitions,
///       each value is a dictionary with:
///         - label: column label content (required)
///         - kind: kind name for fmt() dispatch (optional; auto-detected
///           from value type if omitted). Examples: "pct", "sy", "qty",
///           or a unit string like "m", "t/ha".
///         - fmt: formatting function or none to disable (optional;
///           overrides kind dispatch)
///         - dp: decimal places for this column (optional, overrides kind default)
///         - align: column alignment — left, right, or center (optional;
///           default: right for numeric columns, left for text)
///         - width: column width as a Typst length (optional, default auto)
///         - unit: unit string for kind: "qty" (e.g. "m", "t/ha"). Or
///           use the unit directly as `kind:` (see below).
///       Any other named field is forwarded to the kind's format function.
///   - spanners: dictionary mapping spanner labels to arrays of column keys
///       (optional, for grouped column headers)
///   - dp: default decimal places for all numeric columns (default: auto,
///       meaning each type uses its distiller-format default)
///   - format: per-table type overrides (dictionary, merged with distiller-format)
///   - pivot: column name to pivot on (optional)
///   - pivot-order: array of pivot values in display order (optional)
///   - pivot-labels: dictionary mapping pivot values to display labels (optional)
///   - group-by: column name or array of column names for row grouping (optional)
///   - group-order: array or dictionary of group values in display order (optional)
///   - style: override style options (dictionary, merged with distiller-style)
///
/// Column kind examples:
///   ```
///   columns: (
///     count:  (label: [Count]),                  // auto: int → 0dp
///     rate:   (label: [Rate]),                   // auto: float → 2dp
///     cover:  (label: [Coverage], kind: "pct"),  // → "78.2%"
///     year:   (label: [Year], kind: "sy"),       // → "2008–09"
///     height: (label: [Height], kind: "m", dp: 1), // → "15.4 m"
///     yield:  (label: [Yield], kind: "t/ha"),    // → "124 t ha⁻¹"
///     code:   (label: [Species], fmt: g),        // direct formatter
///     id:     (label: [ID], fmt: none),          // raw value, no formatting
///   )
///   ```
#let distiller-table(
  data,
  columns: (:),
  spanners: none,
  dp: auto,
  format: (:),
  pivot: none,
  pivot-order: none,
  pivot-labels: none,
  group-by: none,
  group-order: none,
  group-label: none,
  filter: none,
  order-by: none,
  style: (:),
) = {
  // Merge style with defaults
  let s = distiller-style
  for (k, v) in style { s.insert(k, v) }

  // Resolved text-element dicts and a small helper that wraps content
  // with only the text properties that aren't inherited (`auto`).
  let header-text  = _resolve-text(s, "header")
  let subhead-text = _resolve-text(s, "subhead")
  let data-text    = _resolve-text(s, "data")
  let with-text(props, body) = {
    let args = (:)
    if props.at("family", default: auto) != auto { args.insert("font", props.family) }
    if props.at("color",  default: auto) != auto { args.insert("fill", props.color) }
    if props.at("weight", default: auto) != auto { args.insert("weight", props.weight) }
    if args.len() == 0 { body } else { text(..args, body) }
  }

  // Apply filter and ordering before pivoting/grouping/rendering.
  // Operating on records form keeps both 2D-array and records-of-dicts
  // input shapes flowing through the same code path.
  if filter != none or order-by != none {
    let recs = if type(data) == array and data.len() > 0 and type(data.at(0)) == dictionary {
      data
    } else {
      records(data)
    }
    if filter != none { recs = recs.filter(filter) }
    if order-by != none { recs = recs.sorted(key: _order-by-key(order-by)) }
    data = recs
  }

  // Merge format overrides with global defaults
  let table-format = distiller-format
  for (k, v) in format { table-format.insert(k, v) }

  // Set table context for fmt() — separator threshold changes to 4 digits
  _distiller-ctx.update(true)

  // ══════════════════════════════════════════════════════════
  // Phase 1: Load data & detect types
  // ══════════════════════════════════════════════════════════
  // Normalize to records with auto-detected types (int/float/str/none).
  let records = records(data)

  // Identify numeric columns from the _kinds sidecar
  let all-cols = if records.len() > 0 { records.at(0).keys().filter(k => k != "_kinds") } else { () }
  let record-kinds = if records.len() > 0 { records.at(0).at("_kinds", default: (:)) } else { (:) }
  let numeric-cols = ()
  for col in all-cols {
    let k = record-kinds.at(col, default: "str")
    if k == "int" or k == "float" or k == "pct" { numeric-cols.push(col) }
  }

  // ══════════════════════════════════════════════════════════
  // Phase 2: Resolve column specifications
  // ══════════════════════════════════════════════════════════
  let columns = if columns.keys().len() == 0 and records.len() > 0 {
    let auto-cols = (:)
    for key in records.at(0).keys() {
      if key != "_kinds" { auto-cols.insert(key, (label: key)) }
    }
    auto-cols
  } else {
    columns
  }
  let col-keys = columns.keys()

  // Convert user spanners to an internal list of (label, columns) entries.
  // Using a list (not a dict) allows content labels (e.g., from pivot-labels).
  let spanner-list = ()
  if spanners != none {
    for (label, cols) in spanners {
      spanner-list.push((label: label, columns: cols))
    }
  }

  // ══════════════════════════════════════════════════════════
  // Phase 3: Pivot — reshape long → wide
  // ══════════════════════════════════════════════════════════
  // After this phase, pivoted data looks like a regular wide table with
  // spanners, so the rendering path is the same for all tables.
  if pivot != none {
    let pivot-values = if pivot-order != none { pivot-order } else {
      let seen = ()
      for r in records {
        let v = r.at(pivot)
        if v not in seen { seen.push(v) }
      }
      seen
    }
    let n-groups = pivot-values.len()

    // Classify columns: row-keys (repeated per pivot group) vs value-keys
    let row-keys = ()
    let value-keys = ()
    for k in col-keys {
      if k == pivot { continue }
      if not all-cols.contains(k) {
        value-keys.push(k) // combined column (e.g., "lower-upper")
      } else {
        let counts = (:)
        for r in records {
          let v = str(r.at(k))
          if v in counts { counts.at(v) += 1 } else { counts.insert(v, 1) }
        }
        if counts.values().all(c => c == n-groups) {
          row-keys.push(k)
        } else {
          value-keys.push(k)
        }
      }
    }

    // Unique row combinations (preserving input order)
    let row-combos = ()
    let seen-combos = ()
    for r in records {
      let combo = row-keys.map(k => r.at(k))
      let combo-key = combo.map(v => str(v)).join("|||")
      if combo-key not in seen-combos {
        seen-combos.push(combo-key)
        row-combos.push(combo)
      }
    }

    // Build wide records: one row per unique row-key combination
    let wide-records = ()
    for combo in row-combos {
      let wide-r = (:)
      for (i, k) in row-keys.enumerate() { wide-r.insert(k, combo.at(i)) }
      for pv in pivot-values {
        let matches = records.filter(r => {
          // str() both sides: a numeric pivot column parses as int/float in the
          // records, while a user-supplied pivot-order arrives as strings, so a
          // bare == never matches. Every other use of pv already normalises.
          str(r.at(pivot)) == str(pv) and row-keys.enumerate().all(((i, k)) => r.at(k) == combo.at(i))
        })
        for key in value-keys {
          let compound = str(pv) + "__" + key
          if matches.len() > 0 {
            let record = matches.at(0)
            if key.contains("-") and not all-cols.contains(key) {
              // Combined column (e.g., "lower-upper"): pre-format now
              let parts = key.split("-")
              let vals = parts.map(p => record.at(p))
              let spec = columns.at(key)
              let display = if "fmt" in spec { (spec.fmt)(..vals) } else { vals.join("–") }
              wide-r.insert(compound, display)
            } else {
              wide-r.insert(compound, record.at(key))
            }
          } else {
            wide-r.insert(compound, none) // no data for this combination
          }
        }
      }
      // Add _kinds sidecar to wide record
      let wide-kinds = (:)
      for k in row-keys {
        if k in record-kinds { wide-kinds.insert(k, record-kinds.at(k)) }
      }
      for pv in pivot-values {
        for key in value-keys {
          let compound = str(pv) + "__" + key
          if key in record-kinds { wide-kinds.insert(compound, record-kinds.at(key)) }
        }
      }
      wide-r.insert("_kinds", wide-kinds)
      wide-records.push(wide-r)
    }
    records = wide-records

    // Expand column specs for the wide layout
    let new-columns = (:)
    let new-col-keys = ()
    for k in row-keys {
      new-columns.insert(k, columns.at(k))
      new-col-keys.push(k)
    }
    for pv in pivot-values {
      for key in value-keys {
        let compound = str(pv) + "__" + key
        let orig = columns.at(key)
        let new-spec = (label: orig.label, _missing: [—])
        if key.contains("-") and not all-cols.contains(key) {
          new-spec.insert("_preformatted", true)
        } else {
          if "fmt" in orig { new-spec.insert("fmt", orig.fmt) }
          if "dp" in orig { new-spec.insert("dp", orig.dp) }
          if "type" in orig { new-spec.insert("type", orig.type) }
        }
        if "align" in orig { new-spec.insert("align", orig.align) } else { new-spec.insert("align", right) }
        if "width" in orig { new-spec.insert("width", orig.width) }
        new-spec.insert("_value-key", key)
        new-columns.insert(compound, new-spec)
        new-col-keys.push(compound)
        if key in numeric-cols { numeric-cols.push(compound) }
      }
    }
    columns = new-columns
    col-keys = new-col-keys

    // Generate pivot spanners
    for pv in pivot-values {
      let label = if pivot-labels != none and str(pv) in pivot-labels {
        pivot-labels.at(str(pv))
      } else {
        // str(): a numeric pivot column yields integer/float values here, and
        // the header cell needs content or a string, not a raw number.
        str(pv)
      }
      let cols = value-keys.map(k => str(pv) + "__" + k)
      spanner-list.push((label: label, columns: cols))
    }
  }

  // ══════════════════════════════════════════════════════════
  // Helpers (defined after all phase mutations so closures
  // capture the final values of columns, numeric-cols, etc.)
  // ══════════════════════════════════════════════════════════
  let get-align(key) = {
    let spec = columns.at(key)
    if "align" in spec { spec.align } else if key in numeric-cols { right } else { left }
  }
  let get-width(key) = {
    let spec = columns.at(key)
    if "width" in spec { spec.width } else { auto }
  }
  // Format a cell value using the fmt() type dispatch system.
  // Precedence: none → _preformatted → fmt: none → fmt: function → type/dp → auto
  let format-cell(key, record) = {
    let spec = columns.at(key)
    let val = record.at(key)
    if val == none {
      return if "_missing" in spec { spec._missing } else { [] }
    }
    if type(val) == str and (val == "NA" or val.trim() == "") { return [] }
    if "_preformatted" in spec and spec._preformatted { return val }
    // fmt: none — raw value, no formatting
    if "fmt" in spec and spec.fmt == none {
      return if type(val) == int or type(val) == float { str(val) } else { val }
    }
    // fmt: function — direct override, bypasses type dispatch
    if "fmt" in spec { return (spec.fmt)(val) }
    // Kind dispatch via fmt() — pass record + field to read sidecar.
    // The column spec field is named `kind:` (matches fmt's `kind:`).
    //
    // Spec fields that aren't internal to distiller-table (label,
    // align, width, kind, dp, fmt, _*) are forwarded as named args
    // to the format function, so kinds like "qty" can pick up extra
    // metadata (e.g. unit: "t/ha") declared once on the column.
    let col-kind = if "kind" in spec { spec.kind } else { auto }
    let col-dp = if "dp" in spec { spec.dp } else if dp != auto { dp } else { auto }
    let internal-keys = ("label", "align", "width", "kind", "dp", "fmt")
    let extra-args = (:)
    for (k, v) in spec {
      if k in internal-keys { continue }
      if k.starts-with("_") { continue }
      extra-args.insert(k, v)
    }
    if extra-args.len() > 0 {
      fmt(record, key, dp: col-dp, kind: col-kind, ..extra-args)
    } else {
      fmt(record, key, dp: col-dp, kind: col-kind)
    }
  }

  // ══════════════════════════════════════════════════════════
  // Phase 4: Group & order records
  // ══════════════════════════════════════════════════════════
  let group-cols = if group-by == none { () } else if type(group-by) == str { (group-by,) } else { group-by }

  // group-label turns the outermost group level into a spanning header
  // row (rather than an inline, repeat-suppressed column). The value is
  // run through a transform: a function (e.g. `gloss(csv(...))`), a
  // `code → label` dictionary, or `auto`/`true` for the raw value.
  let _group-fn = if group-label == none or group-cols.len() == 0 {
    none
  } else if type(group-label) == function {
    group-label
  } else if type(group-label) == dictionary {
    v => if str(v) in group-label { group-label.at(str(v)) } else { v }
  } else {
    v => v
  }
  // The header-row group column is not also shown inline.
  let header-group-col = if _group-fn != none { group-cols.at(0) } else { none }
  if header-group-col != none {
    col-keys = col-keys.filter(k => k != header-group-col)
  }

  let ordered-records = if group-cols.len() > 0 and group-order != none {
    let g-order = if type(group-order) == array {
      let d = (:)
      d.insert(group-cols.at(0), group-order)
      d
    } else {
      group-order
    }
    let sorted = ()
    if group-cols.at(0) in g-order {
      for g0 in g-order.at(group-cols.at(0)) {
        let matching = records.filter(r => str(r.at(group-cols.at(0))) == str(g0))
        if group-cols.len() > 1 and group-cols.at(1) in g-order {
          for g1 in g-order.at(group-cols.at(1)) {
            sorted += matching.filter(r => str(r.at(group-cols.at(1))) == str(g1))
          }
        } else {
          sorted += matching
        }
      }
      sorted
    } else {
      records
    }
  } else {
    records
  }

  // ══════════════════════════════════════════════════════════
  // Phase 5: Build table cells
  // ══════════════════════════════════════════════════════════

  // ── Header cells ──
  let header-cells = ()
  if spanner-list.len() > 0 {
    // Three-row header honouring dict (col-keys) order: each spanner is drawn
    // above the contiguous block of columns it covers, so ungrouped columns may
    // sit before, between, or after spanner groups.  The body iterates col-keys
    // in the same order, so header and data stay aligned.
    let col-spanner = (:)
    for entry in spanner-list {
      for c in entry.columns { col-spanner.insert(c, entry.label) }
    }
    // Segment col-keys into ungrouped single columns and maximal runs of
    // consecutive columns sharing one spanner.
    let segments = ()
    let si = 0
    while si < col-keys.len() {
      let key = col-keys.at(si)
      if key in col-spanner {
        let lbl = col-spanner.at(key)
        let run = ()
        while si < col-keys.len() {
          let k2 = col-keys.at(si)
          if (k2 in col-spanner) and (col-spanner.at(k2) == lbl) {
            run.push(k2)
            si += 1
          } else { break }
        }
        segments.push((span: true, label: lbl, columns: run))
      } else {
        segments.push((span: false, column: key))
        si += 1
      }
    }

    // Row 1: spanner labels (same weight as the column headings) and ungrouped
    // column labels (spanning all three header rows), interleaved in order.
    // A spanner takes the alignment of the last column in its block, so above a
    // run of right-aligned numeric columns it sits flush with the data below.
    for seg in segments {
      if seg.span {
        header-cells.push(table.cell(
          colspan: seg.columns.len(),
          align: get-align(seg.columns.last()),
          // spanner labels are dict keys (strings); eval as markup so math such as
          // "Camera detection ($p_"camera"$)" renders (column labels are already content).
          with-text(header-text, if type(seg.label) == str { eval(seg.label, mode: "markup") } else { seg.label }),
        ))
      } else {
        header-cells.push(table.cell(
          rowspan: 3,
          align: get-align(seg.column) + horizon,
          with-text(header-text, columns.at(seg.column).label),
        ))
      }
    }

    // Row 2: cmidrule lines under each spanner segment (ungrouped columns are
    // already covered by their row-spanning cell above).
    let cmidrule-stroke = _resolve-rule(s, "cmidrule")
    for seg in segments {
      if seg.span {
        header-cells.push(table.cell(
          colspan: seg.columns.len(),
          inset: (x: 0pt, top: s.rule-inset, bottom: s.rule-inset),
          if cmidrule-stroke != none {
            line(length: 100%, stroke: cmidrule-stroke)
          } else { [] },
        ))
      }
    }

    // Row 3: column labels under each spanner segment.
    for seg in segments {
      if seg.span {
        for key in seg.columns {
          header-cells.push(table.cell(
            align: get-align(key),
            with-text(header-text, columns.at(key).label),
          ))
        }
      }
    }
  } else {
    // Single header row
    for key in col-keys {
      header-cells.push(table.cell(
        align: get-align(key),
        with-text(header-text, columns.at(key).label),
      ))
    }
  }

  // ── Data cells (with group suppression and addlinespace) ──
  let data-cells = ()
  let prev-groups = group-cols.map(_ => none)
  // `data-row-idx` counts only actual data rows (not group-space spacers)
  // so alternating row-stripe parity stays stable across the data block.
  let data-row-idx = 0
  for record in ordered-records {
    let current-groups = group-cols.map(k => record.at(k))

    // A spanning group header row when the outermost level changes
    // (group-label active). Carries its own leading space, so the
    // generic group-space spacer below is skipped for this transition.
    let new-top = header-group-col != none and (
      prev-groups.at(0) == none
        or str(current-groups.at(0)) != str(prev-groups.at(0))
    )
    if new-top {
      if prev-groups.at(0) != none {
        data-cells.push(table.cell(colspan: col-keys.len(), inset: (y: s.group-space), []))
      }
      data-cells.push(table.cell(
        colspan: col-keys.len(),
        align: left,
        with-text(subhead-text, [#(_group-fn)(current-groups.at(0))]),
      ))
    }

    // Add spacing when any group level changes (but not for the
    // outermost transition already handled by the header row above)
    if group-cols.len() > 0 and prev-groups.at(0) != none and not new-top {
      let changed = false
      for (i, _) in group-cols.enumerate() {
        if str(current-groups.at(i)) != str(prev-groups.at(i)) { changed = true }
      }
      if changed {
        data-cells.push(table.cell(colspan: col-keys.len(), inset: (y: s.group-space), []))
      }
    }

    let row-fill = if s.row-stripe != none and calc.odd(data-row-idx) {
      s.row-stripe
    } else { none }
    for key in col-keys {
      let val = record.at(key)
      let is-group-col = group-cols.contains(key)
      let display = if is-group-col {
        let gi = group-cols.position(k => k == key)
        let show-val = if prev-groups.at(0) == none { true } else {
          let changed = false
          for i in range(gi + 1) {
            if str(current-groups.at(i)) != str(prev-groups.at(i)) { changed = true }
          }
          changed
        }
        if show-val { format-cell(key, record) } else { [] }
      } else {
        format-cell(key, record)
      }
      let cell-args = (align: get-align(key))
      if row-fill != none { cell-args.insert("fill", row-fill) }
      data-cells.push(table.cell(..cell-args, with-text(data-text, display)))
    }
    prev-groups = current-groups
    data-row-idx += 1
  }

  // ══════════════════════════════════════════════════════════
  // Phase 6: Measure & render
  // ══════════════════════════════════════════════════════════
  set text(
    size: s.font-size,
    ..(if s.text.at("family", default: auto) != auto { (font: s.text.family,) } else { (:) }),
    ..(if s.at("tabular-nums", default: true) { (features: ("tnum",)) } else { (:) }),
  )
  let aligns = col-keys.map(k => get-align(k))

  // Optional booktabs-style rules; resolved once.
  let top-stroke    = _resolve-rule(s, "top-rule")
  let header-stroke = _resolve-rule(s, "header-rule")
  let bottom-stroke = _resolve-rule(s, "bottom-rule")

  context {
    // Measure content-fit width for each column
    let measured-widths = col-keys
      .enumerate()
      .map(((i, key)) => {
        if get-width(key) != auto { return get-width(key) }
        let max-w = measure(columns.at(key).label).width
        for record in ordered-records {
          let content = format-cell(key, record)
          let w = measure([#content]).width
          if w > max-w { max-w = w }
        }
        max-w
      })

    // For pivot tables, equalise widths across repeated value columns
    // so that corresponding columns in each pivot group align uniformly.
    let value-key-maxes = (:)
    for (i, key) in col-keys.enumerate() {
      let spec = columns.at(key)
      if "_value-key" in spec {
        let vk = spec._value-key
        if vk not in value-key-maxes or measured-widths.at(i) > value-key-maxes.at(vk) {
          value-key-maxes.insert(vk, measured-widths.at(i))
        }
      }
    }
    if value-key-maxes.keys().len() > 0 {
      measured-widths = col-keys
        .enumerate()
        .map(((i, key)) => {
          let spec = columns.at(key)
          if "_value-key" in spec { value-key-maxes.at(spec._value-key) } else { measured-widths.at(i) }
        })
    }

    table(
      columns: measured-widths,
      column-gutter: s.gutter,
      align: (col, _) => aligns.at(col),
      stroke: none,
      inset: (x: 0pt, y: s.row-inset),
      ..(if top-stroke    != none { (table.hline(stroke: top-stroke),)    } else { () }),
      table.header(..header-cells),
      ..(if header-stroke != none { (table.hline(stroke: header-stroke),) } else { () }),
      table.cell(colspan: col-keys.len(), inset: (y: s.header-space), []),
      ..data-cells,
      ..(if bottom-stroke != none { (table.hline(stroke: bottom-stroke),) } else { () }),
    )
  }

  // Reset table context
  _distiller-ctx.update(false)
}
