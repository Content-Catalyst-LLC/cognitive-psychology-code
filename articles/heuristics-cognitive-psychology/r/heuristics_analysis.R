#!/usr/bin/env Rscript

# Heuristics in cognitive psychology.
# Hierarchical workflow for anchoring, availability, representativeness,
# recognition, fluency, affect, effort, strategy complexity, correctness,
# calibration, response time, and adaptive fit.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/heuristics_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    condition = factor(condition),
    domain = factor(domain),
    scenario_id = factor(scenario_id),
    heuristic_type = factor(heuristic_type),
    choice_binary = as.integer(choice_binary),
    correct = as.integer(correct),
    log_rt = log(rt_ms)
  )

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    mean_judged_probability = mean(judged_probability, na.rm = TRUE),
    mean_true_probability = mean(true_probability, na.rm = TRUE),
    mean_estimate = mean(estimate, na.rm = TRUE),
    mean_true_value = mean(true_value, na.rm = TRUE),
    choice_rate = mean(choice_binary, na.rm = TRUE),
    correct_rate = mean(correct, na.rm = TRUE),
    mean_rt_ms = mean(rt_ms, na.rm = TRUE),
    mean_confidence = mean(confidence, na.rm = TRUE),
    mean_calibration_error = mean(calibration_error, na.rm = TRUE),
    mean_bias_magnitude = mean(bias_magnitude, na.rm = TRUE),
    mean_adaptive_fit = mean(adaptive_fit, na.rm = TRUE),
    mean_effort = mean(subjective_effort, na.rm = TRUE),
    mean_cue_count = mean(cue_count, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

heuristic_summary <- dat %>%
  group_by(heuristic_type) %>%
  summarise(
    n_trials = n(),
    correct_rate = mean(correct, na.rm = TRUE),
    mean_effort = mean(subjective_effort, na.rm = TRUE),
    mean_rt_ms = mean(rt_ms, na.rm = TRUE),
    mean_calibration_error = mean(calibration_error, na.rm = TRUE),
    mean_bias_magnitude = mean(bias_magnitude, na.rm = TRUE),
    mean_adaptive_fit = mean(adaptive_fit, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(heuristic_summary, file.path(output_dir, "r_summary_by_heuristic.csv"))

anchor_dat <- dat %>% filter(condition %in% c("anchoring", "control", "analytic"))

anchor_model <- lmer(
  estimate ~
    anchor_value * condition +
    true_value +
    cognitive_load +
    subjective_effort +
    (1 + anchor_value | participant) +
    (1 | scenario_id),
  data = anchor_dat,
  REML = FALSE
)

availability_dat <- dat %>% filter(condition %in% c("availability", "control", "analytic"))

availability_model <- lmer(
  judged_probability ~
    recall_ease * condition +
    true_probability +
    affective_valence +
    cognitive_load +
    (1 + recall_ease | participant) +
    (1 | scenario_id),
  data = availability_dat,
  REML = FALSE
)

represent_dat <- dat %>% filter(condition %in% c("representativeness", "control", "analytic"))

represent_model <- lmer(
  judged_probability ~
    representativeness * condition +
    base_rate +
    base_rate_use +
    true_probability +
    cognitive_load +
    (1 + representativeness | participant) +
    (1 | scenario_id),
  data = represent_dat,
  REML = FALSE
)

correct_model <- glmer(
  correct ~
    condition +
    domain +
    heuristic_type +
    cue_validity +
    cue_count +
    information_cost +
    time_pressure +
    cognitive_load +
    strategy_complexity +
    subjective_effort +
    base_rate_use +
    confidence +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

bias_model <- lmer(
  bias_magnitude ~
    condition +
    domain +
    heuristic_type +
    anchor_value +
    recall_ease +
    representativeness +
    recognition_strength +
    fluency +
    affective_valence +
    base_rate_use +
    time_pressure +
    cognitive_load +
    subjective_effort +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

calibration_model <- lmer(
  calibration_error ~
    condition +
    domain +
    heuristic_type +
    recall_ease +
    representativeness +
    base_rate_use +
    cue_validity +
    cognitive_load +
    confidence +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

effort_model <- lmer(
  subjective_effort ~
    condition +
    domain +
    heuristic_type +
    cue_count +
    information_cost +
    strategy_complexity +
    time_pressure +
    cognitive_load +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

rt_model <- lmer(
  log_rt ~
    condition +
    domain +
    heuristic_type +
    cue_count +
    information_cost +
    time_pressure +
    cognitive_load +
    strategy_complexity +
    subjective_effort +
    correct +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

adaptive_model <- lmer(
  adaptive_fit ~
    condition +
    domain +
    heuristic_type +
    cue_validity +
    cue_count +
    information_cost +
    time_pressure +
    cognitive_load +
    strategy_complexity +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    anchor_model = summary(anchor_model),
    availability_model = summary(availability_model),
    representativeness_model = summary(represent_model),
    correct_model = summary(correct_model),
    bias_model = summary(bias_model),
    calibration_model = summary(calibration_model),
    effort_model = summary(effort_model),
    response_time_model = summary(rt_model),
    adaptive_fit_model = summary(adaptive_model),
    condition_correct = emmeans(correct_model, ~ condition, type = "response"),
    heuristic_correct = emmeans(correct_model, ~ heuristic_type, type = "response")
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(anchor_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_anchor_coefficients.csv"))
write_csv(tidy(availability_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_availability_coefficients.csv"))
write_csv(tidy(represent_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_representativeness_coefficients.csv"))
write_csv(tidy(correct_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_correct_coefficients.csv"))
write_csv(tidy(bias_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_bias_coefficients.csv"))
write_csv(tidy(calibration_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_calibration_coefficients.csv"))
write_csv(tidy(effort_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_effort_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_coefficients.csv"))
write_csv(tidy(adaptive_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_adaptive_fit_coefficients.csv"))

p <- ggplot(dat, aes(x = anchor_value, y = estimate, color = condition)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Anchoring and judgment estimates",
    x = "Anchor value",
    y = "Estimate"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_anchoring_estimates.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
