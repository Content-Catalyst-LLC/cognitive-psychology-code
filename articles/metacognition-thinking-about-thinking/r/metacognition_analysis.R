#!/usr/bin/env Rscript

# Metacognition in cognitive psychology.
# Hierarchical workflow for calibration, confidence, monitoring, control, and regulation.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/metacognition_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    condition = factor(condition),
    task_id = factor(task_id),
    domain = factor(domain),
    actual_accuracy = as.integer(actual_accuracy),
    strategy_shift = as.integer(strategy_shift),
    review_choice = as.integer(review_choice),
    feedback_used = as.integer(feedback_used),
    calibration_error = abs(confidence_rating - actual_accuracy),
    signed_calibration = confidence_rating - actual_accuracy,
    log_response_time = log(response_time_ms)
  )

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    mean_difficulty = mean(task_difficulty, na.rm = TRUE),
    mean_evidence_quality = mean(evidence_quality, na.rm = TRUE),
    mean_confidence = mean(confidence_rating, na.rm = TRUE),
    mean_uncertainty = mean(uncertainty_rating, na.rm = TRUE),
    accuracy_rate = mean(actual_accuracy, na.rm = TRUE),
    mean_calibration_error = mean(calibration_error, na.rm = TRUE),
    mean_signed_calibration = mean(signed_calibration, na.rm = TRUE),
    strategy_shift_rate = mean(strategy_shift, na.rm = TRUE),
    review_choice_rate = mean(review_choice, na.rm = TRUE),
    feedback_use_rate = mean(feedback_used, na.rm = TRUE),
    mean_study_time_seconds = mean(study_time_seconds, na.rm = TRUE),
    mean_response_time_ms = mean(response_time_ms, na.rm = TRUE),
    mean_regulation_score = mean(metacognitive_regulation_score, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

calibration_model <- lmer(
  calibration_error ~
    condition +
    domain +
    task_difficulty +
    evidence_quality +
    uncertainty_rating +
    judgment_of_learning +
    feedback_used +
    (1 | participant) +
    (1 | task_id),
  data = dat,
  REML = FALSE
)

signed_model <- lmer(
  signed_calibration ~
    condition +
    domain +
    task_difficulty +
    evidence_quality +
    actual_accuracy +
    uncertainty_rating +
    (1 | participant) +
    (1 | task_id),
  data = dat,
  REML = FALSE
)

shift_model <- glmer(
  strategy_shift ~
    condition +
    domain +
    confidence_rating +
    uncertainty_rating +
    actual_accuracy +
    task_difficulty +
    evidence_quality +
    feedback_used +
    (1 | participant) +
    (1 | task_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

review_model <- glmer(
  review_choice ~
    condition +
    domain +
    calibration_error +
    uncertainty_rating +
    task_difficulty +
    confidence_rating +
    feedback_used +
    (1 | participant) +
    (1 | task_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

regulation_model <- lmer(
  metacognitive_regulation_score ~
    condition +
    domain +
    calibration_error +
    strategy_shift +
    review_choice +
    feedback_used +
    task_difficulty +
    evidence_quality +
    (1 | participant) +
    (1 | task_id),
  data = dat,
  REML = FALSE
)

rt_model <- lmer(
  log_response_time ~
    condition +
    domain +
    task_difficulty +
    confidence_rating +
    uncertainty_rating +
    strategy_shift +
    actual_accuracy +
    (1 | participant) +
    (1 | task_id),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    calibration_model = summary(calibration_model),
    signed_calibration_model = summary(signed_model),
    strategy_shift_model = summary(shift_model),
    review_choice_model = summary(review_model),
    regulation_quality_model = summary(regulation_model),
    response_time_model = summary(rt_model),
    condition_calibration = emmeans(calibration_model, ~ condition),
    condition_strategy_shift = emmeans(shift_model, ~ condition, type = "response"),
    condition_review_choice = emmeans(review_model, ~ condition, type = "response")
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(calibration_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_calibration_coefficients.csv"))
write_csv(tidy(signed_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_signed_calibration_coefficients.csv"))
write_csv(tidy(shift_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_strategy_shift_coefficients.csv"))
write_csv(tidy(review_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_review_choice_coefficients.csv"))
write_csv(tidy(regulation_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_regulation_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_coefficients.csv"))

p <- ggplot(dat, aes(x = confidence_rating, y = actual_accuracy, color = condition)) +
  geom_point(alpha = 0.25, position = position_jitter(width = 0.01, height = 0.03)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  labs(
    title = "Metacognitive calibration",
    x = "Confidence rating",
    y = "Actual accuracy"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_metacognitive_calibration.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
