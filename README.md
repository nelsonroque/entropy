# Entropy & Diversity Indices Toolkit (R / tidyverse)

## Overview

This repository provides a **tidyverse-friendly toolkit** for computing entropy and diversity indices on grouped data. It is designed for behavioral, cognitive, and social science applications where researchers want to quantify **how evenly activity is distributed across categories** (e.g., devices, apps, locations, behaviors).

The toolkit supports:

* **Shannon entropy** (optionally normalized, any log base)
* **Simpson diversity index**
* **Gini coefficient** (inequality of proportions)
* Optional **weights** (e.g., intensity × duration)
* Clear **ELI5-style documentation** for teaching and onboarding

---

## Typical Use Case

> “For each day, how evenly is screen time distributed across devices?”

Examples:

* Screen time across devices per day
* App usage across categories per person
* Location visits across places per week
* Behavioral responses across task types

Higher diversity ≠ more time — it means **time is spread more evenly**.

---

## Installation / Requirements

```r
library(tidyverse)
```

No additional dependencies required.

---

## Functions Included

### 1. `compute_entropy2()`

Computes selected entropy/diversity indices **within groups**.

#### Function signature

```r
compute_entropy2(
  data,
  group_var,
  value_var,
  indices = c("shannon", "gini", "simpson"),
  shannon_base = exp(1),
  normalize_shannon = FALSE,
  weight_var = NULL,
  keep_vars = FALSE
)
```

#### Arguments

| Argument            | Description                                                      |
| ------------------- | ---------------------------------------------------------------- |
| `data`              | A data frame                                                     |
| `group_var`         | Grouping variable (e.g., day, participant_id)                    |
| `value_var`         | Numeric values used to compute proportions (e.g., minutes)       |
| `indices`           | Any combination of `"shannon"`, `"gini"`, `"simpson"`            |
| `shannon_base`      | Log base for Shannon entropy (`exp(1)` = nats, `2` = bits)       |
| `normalize_shannon` | If `TRUE`, computes Shannon / log(k)                             |
| `weight_var`        | Optional numeric weight (value becomes value × weight)           |
| `keep_vars`         | If `TRUE`, keeps diagnostics like total and number of categories |

---

### 2. `eli5_entropy()`

Returns a **plain-language explanation table** describing each index.

```r
eli5_entropy()
```

Useful for:

* Methods sections
* Supplementary materials
* Lab documentation

---

## Example Data

```r
set.seed(123)

screen_time <- tibble(
  day = rep(1:10, each = 4),
  device = rep(c("Phone", "Laptop", "Tablet", "TV"), times = 10),
  minutes = round(runif(40, 10, 180)),
  grid_memory_error_distance = round(runif(40, 0.5, 2.0), 2)
)
```

---

## Example Usage

### Unweighted diversity per day (normalized Shannon in bits)

```r
compute_entropy2(
  screen_time,
  group_var = day,
  value_var = minutes,
  indices = c("shannon", "simpson", "gini"),
  shannon_base = 2,
  normalize_shannon = TRUE
)
```

**Interpretation**

* Shannon (normalized): how evenly screen time is split across devices
* Simpson: probability two random minutes come from different devices
* Gini: inequality of device usage

---

### Weighted diversity (minutes × cognitive load)

```r
compute_entropy2(
  screen_time,
  group_var = day,
  value_var = minutes,
  indices = c("shannon", "simpson", "gini"),
  shannon_base = 2,
  normalize_shannon = TRUE,
  weight_var = grid_memory_error_distance,
  keep_vars = TRUE
)
```

**Interpretation**
Now diversity reflects **weighted exposure**, not raw time.
This is useful when minutes differ in effort, intensity, or relevance.

---

## Conceptual Notes (Read This First)

### What these indices are *not*

* They do **not** measure total usage
* They do **not** measure performance or quality
* They do **not** imply “better” or “worse” without theory

### What they *do* measure

> **How evenly activity is distributed across categories**

---

## Index Interpretations (ELI5)

| Index              | Intuition                                                           |
| ------------------ | ------------------------------------------------------------------- |
| Shannon entropy    | “How surprising is it which category comes next?”                   |
| Normalized Shannon | Same as Shannon, but scaled 0–1 for comparability                   |
| Simpson diversity  | “If I pick two random observations, how likely are they different?” |
| Gini               | “How unequal is the distribution?”                                  |

Run this to see full explanations:

```r
eli5_entropy()
```

---

## Best Practices for Students

* Always plot raw proportions before interpreting entropy
* Report **which base** was used for Shannon
* Use **normalized Shannon** when comparing across different numbers of categories
* Justify weights theoretically (don’t add them casually)
* Treat entropy as a **descriptive or predictor variable**, not an outcome without theory

---

## Common Pitfalls

* Using entropy on values with negative numbers ❌
* Forgetting that weights change the meaning of the metric ❌
* Comparing raw Shannon across different `k` ❌
* Interpreting high entropy as “more screen time” ❌

---

## Suggested Extensions

* Person-level mean and variability of entropy
* Multilevel models with entropy as a time-varying predictor
* Joint modeling of entropy and total usage
* Visualization of entropy trajectories over time

---

## Contact / Maintenance

Maintained for internal lab use by Dr. Nelson Roque (nur375@psu.edu).
If you modify this function, **update the README and examples** so future students understand the assumptions.
