#!/usr/bin/env Rscript

# Mental models in cognitive psychology.
# Hierarchical workflow for model quality, prediction error, problem success,
# causal structure, transfer, and model revision.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/mental_models_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    condition = factor(condition),
    domain = factor(domain),
    scenario_id = factor(scenario_id),
    problem_success = as.integer(problem_success),
    intervention_choice_accuracy = as.integer(intervention_choice_accuracy),
    log_reasoning_time = log(reasoning_time_ms)
  )

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    mean_completeness = mean(model_completeness, na.rm = TRUE),
    mean_coherence = mean(model_coherence, na.rm = TRUE),
    mean_causal_accuracy = mean(causal_link_accuracy, na.rm = TRUE),
    mean_feedback_loop_recognition = mean(feedback_loop_recognition, na.rm = TRUE),
    mean_boundary_accuracy = mean(boundary_accuracy, na.rm = TRUE),
    mean_prediction_error = mean(prediction_error, na.rm = TRUE),
    mean_system_understanding = mean(system_understanding_score, na.rm = TRUE),
    success_rate = mean(problem_success, na.rm = TRUE),
    intervention_accuracy = mean(intervention_choice_accuracy, na.rm = TRUE),
    mean_revision = mean(model_revision_score, na.rm = TRUE),
    mean_transfer = mean(transfer_score, na.rm = TRUE),
    mean_cognitive_load = mean(cognitive_load, na.rm = TRUE),
    mean_explanation_quality = mean(explanation_quality, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

prediction_error_model <- lmer(
  prediction_error ~
    condition +
    domain +
    model_completeness +
    model_coherence +
    causal_link_accuracy +
    feedback_loop_recognition +
    boundary_accuracy +
    structural_similarity +
    cognitive_load +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

understanding_model <- lmer(
  system_understanding_score ~
    condition +
    domain +
    model_completeness +
    model_coherence +
    causal_link_accuracy +
    feedback_loop_recognition +
    boundary_accuracy +
    cognitive_load +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

success_model <- glmer(
  problem_success ~
    condition +
    domain +
    system_understanding_score +
    prediction_error +
    causal_link_accuracy +
    feedback_loop_recognition +
    boundary_accuracy +
    confidence +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

intervention_model <- glmer(
  intervention_choice_accuracy ~
    condition +
    domain +
    causal_link_accuracy +
    feedback_loop_recognition +
    boundary_accuracy +
    system_understanding_score +
    prediction_error +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

revision_model <- lmer(
  model_revision_score ~
    condition +
    domain +
    prediction_error +
    feedback_loop_recognition +
    causal_link_accuracy +
    model_coherence +
    cognitive_load +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

transfer_model <- lmer(
  transfer_score ~
    condition +
    domain +
    structural_similarity +
    model_coherence +
    causal_link_accuracy +
    boundary_accuracy +
    system_understanding_score +
    problem_success +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

reasoning_time_model <- lmer(
  log_reasoning_time ~
    condition +
    domain +
    model_coherence +
    cognitive_load +
    prediction_error +
    system_understanding_score +
    problem_success +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    prediction_error_model = summary(prediction_error_model),
    understanding_model = summary(understanding_model),
    success_model = summary(success_model),
    intervention_model = summary(intervention_model),
    revision_model = summary(revision_model),
    transfer_model = summary(transfer_model),
    reasoning_time_model = summary(reasoning_time_model),
    condition_prediction_error = emmeans(prediction_error_model, ~ condition),
    condition_success = emmeans(success_model, ~ condition, type = "response"),
    condition_transfer = emmeans(transfer_model, ~ condition)
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(prediction_error_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_prediction_error_coefficients.csv"))
write_csv(tidy(understanding_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_understanding_coefficients.csv"))
write_csv(tidy(success_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_success_coefficients.csv"))
write_csv(tidy(intervention_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_intervention_coefficients.csv"))
write_csv(tidy(revision_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_revision_coefficients.csv"))
write_csv(tidy(transfer_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_transfer_coefficients.csv"))
write_csv(tidy(reasoning_time_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_reasoning_time_coefficients.csv"))

p <- ggplot(dat, aes(x = system_understanding_score, y = prediction_error, color = condition)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "System understanding and prediction error",
    x = "System understanding score",
    y = "Prediction error"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_system_understanding_prediction_error.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
