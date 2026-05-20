#!/usr/bin/env Rscript

# Cognitive biases in decision making.
# Hierarchical workflow for framing, anchoring, confirmation bias,
# overconfidence, calibration error, prospect-theory features, risky choice,
# decision quality, response time, and debiasing effects.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/cognitive_bias_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    condition = factor(condition),
    domain = factor(domain),
    scenario_id = factor(scenario_id),
    bias_type = factor(bias_type),
    frame = factor(frame),
    gain_loss = factor(gain_loss),
    debiasing_condition = factor(debiasing_condition),
    chose_risky = as.integer(chose_risky),
    choice_binary = as.integer(choice_binary),
    correct = as.integer(correct),
    institutional_review_flag = as.integer(institutional_review_flag),
    log_rt = log(response_time_ms)
  )

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    mean_confidence = mean(confidence_rating, na.rm = TRUE),
    mean_accuracy = mean(actual_accuracy, na.rm = TRUE),
    mean_calibration_error = mean(calibration_error, na.rm = TRUE),
    mean_overconfidence = mean(overconfidence, na.rm = TRUE),
    risky_choice_rate = mean(chose_risky, na.rm = TRUE),
    correct_rate = mean(correct, na.rm = TRUE),
    mean_decision_quality = mean(decision_quality, na.rm = TRUE),
    review_flag_rate = mean(institutional_review_flag, na.rm = TRUE),
    mean_rt_ms = mean(response_time_ms, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

bias_summary <- dat %>%
  group_by(bias_type) %>%
  summarise(
    n_trials = n(),
    correct_rate = mean(correct, na.rm = TRUE),
    mean_calibration_error = mean(calibration_error, na.rm = TRUE),
    mean_overconfidence = mean(overconfidence, na.rm = TRUE),
    risky_choice_rate = mean(chose_risky, na.rm = TRUE),
    mean_decision_quality = mean(decision_quality, na.rm = TRUE),
    review_flag_rate = mean(institutional_review_flag, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(bias_summary, file.path(output_dir, "r_summary_by_bias_type.csv"))

calibration_model <- lmer(
  calibration_error ~
    condition +
    domain +
    bias_type +
    frame +
    gain_loss +
    confidence_rating +
    actual_accuracy +
    cognitive_load +
    time_pressure +
    debiasing_condition +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

overconfidence_model <- lmer(
  overconfidence ~
    condition +
    domain +
    bias_type +
    confidence_rating +
    actual_accuracy +
    confirmation_congruence +
    cognitive_load +
    time_pressure +
    debiasing_condition +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

risky_model <- glmer(
  chose_risky ~
    condition +
    frame * gain_loss +
    probability +
    payoff +
    probability_weight +
    subjective_value +
    loss_aversion_lambda +
    cognitive_load +
    time_pressure +
    debiasing_condition +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

correct_model <- glmer(
  correct ~
    condition +
    domain +
    bias_type +
    base_rate +
    representativeness +
    confirmation_congruence +
    confidence_rating +
    calibration_error +
    cognitive_load +
    time_pressure +
    debiasing_condition +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

quality_model <- lmer(
  decision_quality ~
    condition +
    domain +
    bias_type +
    correct +
    calibration_error +
    overconfidence +
    cognitive_load +
    time_pressure +
    debiasing_condition +
    institutional_review_flag +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

review_model <- glmer(
  institutional_review_flag ~
    condition +
    domain +
    bias_type +
    calibration_error +
    overconfidence +
    cognitive_load +
    time_pressure +
    decision_quality +
    debiasing_condition +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

rt_model <- lmer(
  log_rt ~
    condition +
    domain +
    bias_type +
    calibration_error +
    cognitive_load +
    time_pressure +
    correct +
    debiasing_condition +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    calibration_model = summary(calibration_model),
    overconfidence_model = summary(overconfidence_model),
    risky_choice_model = summary(risky_model),
    correct_model = summary(correct_model),
    decision_quality_model = summary(quality_model),
    institutional_review_model = summary(review_model),
    response_time_model = summary(rt_model),
    risky_choice_by_frame = emmeans(risky_model, ~ frame * gain_loss, type = "response"),
    calibration_by_debiasing = emmeans(calibration_model, ~ debiasing_condition),
    quality_by_condition = emmeans(quality_model, ~ condition)
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(calibration_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_calibration_coefficients.csv"))
write_csv(tidy(overconfidence_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_overconfidence_coefficients.csv"))
write_csv(tidy(risky_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_risky_choice_coefficients.csv"))
write_csv(tidy(correct_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_correct_coefficients.csv"))
write_csv(tidy(quality_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_decision_quality_coefficients.csv"))
write_csv(tidy(review_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_review_flag_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_coefficients.csv"))

p <- ggplot(dat, aes(x = actual_accuracy, y = confidence_rating, color = condition)) +
  geom_point(alpha = 0.25) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  labs(
    title = "Confidence calibration by condition",
    x = "Actual accuracy",
    y = "Confidence rating"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_confidence_calibration.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
