source("functions.R")

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

# =============================================================================
# Check Assumptions: Correlations Between Indices
# =============================================================================

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
