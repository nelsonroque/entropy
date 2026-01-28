source("functions.R")

# =============================================================================
# 5) Explain Each Outcome (for reports / onboarding)
# =============================================================================
eli5_entropy()

meds <- tibble(
  person_id = c(1,1,1,2,2,3),
  med_name  = c("A","B","C","D","E","F"),
  color     = c("Red","White","Red","Blue","Blue","Red"),
  shape     = c("Round","Oval","Round","Oval","Round","Round")
)

color_counts <- meds %>%
  count(person_id, color, name = "n_color")

color_entropy <- compute_entropy2(
  data = color_counts,
  group_var = person_id,
  value_var = n_color,
  indices = c("shannon", "simpson", "gini"),
  shannon_base = 2,
  normalize_shannon = TRUE
)

color_entropy
