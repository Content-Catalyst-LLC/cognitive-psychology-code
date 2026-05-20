#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)
input_path <- ifelse(length(args) >= 1, args[[1]], "data/perception_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    condition = factor(condition),
    domain = factor(domain),
    stimulus_id = factor(stimulus_id),
    modality = factor(modality),
    signal_present = as.integer(signal_present),
    response_yes = as.integer(response_yes),
    correct = as.integer(correct),
    log_rt = log(response_time_ms)
  )

sdt <- dat %>%
  group_by(participant, condition) %>%
  summarise(
    hits = sum(signal_present == 1 & response_yes == 1, na.rm = TRUE),
    misses = sum(signal_present == 1 & response_yes == 0, na.rm = TRUE),
    false_alarms = sum(signal_present == 0 & response_yes == 1, na.rm = TRUE),
    correct_rejections = sum(signal_present == 0 & response_yes == 0, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    hit_rate = (hits + 0.5) / (hits + misses + 1),
    false_alarm_rate = (false_alarms + 0.5) / (false_alarms + correct_rejections + 1),
    dprime = qnorm(hit_rate) - qnorm(false_alarm_rate),
    criterion = -0.5 * (qnorm(hit_rate) + qnorm(false_alarm_rate))
  )

write_csv(sdt, file.path(output_dir, "r_signal_detection_by_participant_condition.csv"))

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    correct_rate = mean(correct, na.rm = TRUE),
    yes_rate = mean(response_yes, na.rm = TRUE),
    mean_confidence = mean(confidence, na.rm = TRUE),
    mean_response_time_ms = mean(response_time_ms, na.rm = TRUE),
    mean_sensory_evidence = mean(sensory_evidence, na.rm = TRUE),
    mean_prediction_error = mean(prediction_error, na.rm = TRUE),
    mean_threshold = mean(perceptual_threshold, na.rm = TRUE),
    mean_noise = mean(noise_level, na.rm = TRUE),
    mean_attention_gain = mean(attention_gain, na.rm = TRUE),
    mean_context_strength = mean(context_strength, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

response_model <- glmer(
  response_yes ~
    condition + modality + stimulus_level + signal_present + sensory_evidence +
    prior_expectation + cue_quality + attention_gain + context_strength + noise_level +
    prediction_error + multisensory_congruence + interface_salience +
    (1 + stimulus_level | participant) + (1 | stimulus_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

accuracy_model <- glmer(
  correct ~
    condition + modality + stimulus_level + sensory_evidence + cue_quality +
    attention_gain + context_strength + noise_level + prediction_error +
    perceptual_threshold + visual_search_set_size + distractor_similarity +
    perceptual_learning_block + interface_salience +
    (1 + stimulus_level | participant) + (1 | stimulus_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

threshold_model <- lmer(
  perceptual_threshold ~
    condition + modality + noise_level + attention_gain + cue_quality +
    context_strength + visual_search_set_size + distractor_similarity +
    perceptual_learning_block + (1 | participant),
  data = dat,
  REML = FALSE
)

prediction_model <- lmer(
  prediction_error ~
    condition + modality + stimulus_level + prior_expectation + cue_quality +
    context_strength + noise_level + multisensory_congruence +
    (1 | participant) + (1 | stimulus_id),
  data = dat,
  REML = FALSE
)

rt_model <- lmer(
  log_rt ~
    condition + modality + correct + confidence + sensory_evidence + noise_level +
    attention_gain + prediction_error + visual_search_set_size +
    distractor_similarity + interface_salience +
    (1 + stimulus_level | participant) + (1 | stimulus_id),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    response_model = summary(response_model),
    accuracy_model = summary(accuracy_model),
    threshold_model = summary(threshold_model),
    prediction_error_model = summary(prediction_model),
    response_time_model = summary(rt_model),
    response_by_condition = emmeans(response_model, ~ condition, type = "response"),
    accuracy_by_condition = emmeans(accuracy_model, ~ condition, type = "response")
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(response_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_yes_coefficients.csv"))
write_csv(tidy(accuracy_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_accuracy_coefficients.csv"))
write_csv(tidy(threshold_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_threshold_coefficients.csv"))
write_csv(tidy(prediction_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_prediction_error_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_coefficients.csv"))

psy <- dat %>%
  group_by(condition, stimulus_level) %>%
  summarise(p_yes = mean(response_yes), .groups = "drop")

p <- ggplot(psy, aes(x = stimulus_level, y = p_yes, color = condition)) +
  geom_point(alpha = 0.7) +
  geom_smooth(method = "glm", method.args = list(family = "binomial"), se = FALSE) +
  labs(title = "Psychometric response function", x = "Stimulus level", y = "P(response yes)") +
  theme_minimal(base_size = 12)

ggsave(file.path(output_dir, "r_psychometric_curve.png"), p, width = 9, height = 6, dpi = 300)

message("R analysis complete. Outputs written to: ", output_dir)
