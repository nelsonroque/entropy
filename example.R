library(tidyverse)

# =============================================================================
# Entropy / Diversity Indices Toolkit
# =============================================================================
# Purpose:
#   Provide a generic way to compute Shannon entropy, normalized Shannon,
#   Simpson diversity, and Gini inequality on grouped data (e.g., per day).
#
# Typical use case:
#   Within each day, compute diversity of device usage based on minutes (or
#   minutes * weight). Higher diversity means usage is more evenly spread across
#   devices; lower diversity means one device dominates.
# =============================================================================


# =============================================================================
# 1) ELI5 Documentation Helper
# =============================================================================
# Returns a table explaining each index in plain language.
# Useful for lab documentation, onboarding, and report appendices.
eli5_entropy <- function() {
  tibble::tribble(
    ~index, ~eli5, ~in_our_screen_time_example, ~range_hint,
    "Shannon entropy (H)",
    "How 'uncertain' the next device is. If time is evenly spread across devices, Shannon is higher. If one device dominates, Shannon is lower.",
    "Higher when minutes are spread across devices; lower when one device takes most minutes.",
    ">= 0; max is log_base(k)",
    "Normalized Shannon (H / log(k))",
    "Shannon entropy scaled so it’s easier to compare across days with different numbers of devices. 0 = one device; 1 = perfectly even.",
    "Lets you compare days even if some days have fewer devices recorded.",
    "0 to 1 (when k > 1)",
    "Simpson diversity (1 - sum p^2)",
    "If you pick two random minutes, how likely they come from different devices. More mixing means higher Simpson.",
    "Higher when balanced across devices; lower when one device dominates.",
    "0 to near 1",
    "Gini (inequality of proportions)",
    "How unequal the distribution is. If one device hogs most minutes, Gini is high; if evenly spread, Gini is low.",
    "Higher when one device dominates; lower when minutes are evenly split.",
    "0 to 1 (common use)"
  )
}


# =============================================================================
# 2) Core Function: compute_entropy2()
# =============================================================================
# Computes selected indices per group.
#
# Arguments:
#   data            : a data frame
#   group_var       : grouping variable (e.g., day)
#   value_var       : nonnegative numeric values (e.g., minutes)
#   indices         : any of c("shannon","gini","simpson")
#   shannon_base    : log base for Shannon (exp(1)=nats, 2=bits, 10=hartleys)
#   normalize_shannon: TRUE to compute H/log(k)
#   weight_var      : optional numeric weight column (value becomes value*weight)
#   keep_vars       : TRUE to retain helpful diagnostics (k, total)
#
# Notes:
#   - All indices operate on proportions p = value / sum(value) within each group.
#   - k is the number of nonzero categories in the group.
compute_entropy2 <- function(
  data,
  group_var,
  value_var,
  indices = c("shannon", "gini", "simpson"),
  shannon_base = exp(1),         # exp(1) = natural log base (nats); use 2 for bits
  normalize_shannon = FALSE,     # TRUE -> H / log_base(k)
  weight_var = NULL,             # optional column to weight value_var (e.g., intensity)
  keep_vars = FALSE
) {
  indices <- match.arg(
    indices,
    choices = c("shannon", "gini", "simpson"),
    several.ok = TRUE
  )

  # ---- Input checks (lightweight but helpful)
  if (!is.numeric(pull(data, {{ value_var }}))) {
    stop("value_var must be numeric.")
  }

  # ---- Apply optional weights
  data2 <- if (is.null(weight_var)) {
    data %>% mutate(.val = {{ value_var }})
  } else {
    if (!is.numeric(pull(data, {{ weight_var }}))) {
      stop("weight_var must be numeric if provided.")
    }
    data %>% mutate(.val = {{ value_var }} * {{ weight_var }})
  }

  # ---- Compute proportions within each group
  out <- data2 %>%
    group_by({{ group_var }}) %>%
    summarise(
      .total = sum(.val, na.rm = TRUE),
      .p = list(if (.total > 0) .val / .total else rep(NA_real_, length(.val))),
      .k = sum((.val / .total) > 0, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    rowwise() %>%
    mutate(
      # Shannon entropy (optionally normalized)
      shannon = if ("shannon" %in% indices) {
        p <- .p
        # log base conversion: log_b(x) = log(x)/log(b)
        H <- -sum(p * (log(p) / log(shannon_base)), na.rm = TRUE)
        if (normalize_shannon) {
          if (.k <= 1) 0 else H / (log(.k) / log(shannon_base))
        } else {
          H
        }
      } else NA_real_,

      # Gini on proportions (inequality)
      gini = if ("gini" %in% indices) {
        p <- sort(.p)
        n <- length(p)
        sum((2 * seq_len(n) - n - 1) * p, na.rm = TRUE) / n
      } else NA_real_,

      # Simpson diversity
      simpson = if ("simpson" %in% indices) {
        p <- .p
        1 - sum(p^2, na.rm = TRUE)
      } else NA_real_
    ) %>%
    ungroup()

  # ---- Return with or without diagnostics
  if (keep_vars) {
    out %>% select({{ group_var }}, .total, .k, shannon, gini, simpson)
  } else {
    out %>% select({{ group_var }}, shannon, gini, simpson)
  }
}


# =============================================================================
# 3) Example Data: Screen Time Over 10 Days (with a weight variable)
# =============================================================================
set.seed(123)

screen_time <- tibble(
  day = rep(1:10, each = 4),
  device = rep(c("Phone", "Laptop", "Tablet", "TV"), times = 10),
  minutes = round(runif(40, 10, 180)),
  grid_memory_error_distance = round(runif(40, 0.5, 2.0), 2)
)

screen_time


# =============================================================================
# 4) Example Calls
# =============================================================================

# (A) Unweighted diversity per day (normalized Shannon in BITS)
entropy_unweighted <- compute_entropy2(
  screen_time,
  group_var = day,
  value_var = minutes,
  indices = c("shannon", "simpson", "gini"),
  shannon_base = 2,
  normalize_shannon = TRUE
)

# (B) Weighted diversity per day: minutes * grid_memory_error_distance
# Interpretation: "weighted minutes" might reflect more 'impactful' or 'effortful'
# screen time if the weight captures cognitive load, error, intensity, etc.
# TODO: fix issue with weighted version
# entropy_weighted <- compute_entropy2(
#   screen_time,
#   group_var = day,
#   value_var = minutes,
#   indices = c("shannon", "simpson", "gini"),
#   shannon_base = 2,
#   normalize_shannon = TRUE,
#   weight_var = grid_memory_error_distance,
#   keep_vars = TRUE
# )

# =============================================================================
# Check Assumptions: Correlations Between Indices
# =============================================================================

entropy_weighted
entropy_unweighted

cor.test(
  entropy_unweighted$shannon,
  entropy_unweighted$simpson
)

cor.test(
  entropy_unweighted$shannon,
  entropy_unweighted$gini
)

cor.test(
  entropy_unweighted$simpson,
  entropy_unweighted$gini
)

# =============================================================================
# 5) Explain Each Outcome (for reports / onboarding)
# =============================================================================
eli5_entropy()
