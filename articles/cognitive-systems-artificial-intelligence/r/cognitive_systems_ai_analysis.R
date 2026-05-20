#!/usr/bin/env Rscript

# Cognitive systems in artificial intelligence.
# Hierarchical and descriptive workflow for cognitive psychologists,
# AI researchers, HCI researchers, and decision scientists.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/cognitive_systems_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    agent_id = factor(agent_id),
    architecture = factor(architecture),
    task_condition = factor(task_condition),
    action_success = as.integer(action_success),
    override_decision = as.integer(override_decision),
    log_response_time = log(response_time_ms)
  )

architecture_summary <- dat %>%
  group_by(architecture) %>%
  summarise(
    n_trials = n(),
    agents = n_distinct(agent_id),
    mean_representation = mean(representation_quality, na.rm = TRUE),
    mean_retrieval_latency_ms = mean(retrieval_latency_ms, na.rm = TRUE),
    mean_uncertainty = mean(uncertainty_level, na.rm = TRUE),
    mean_policy_entropy = mean(policy_entropy, na.rm = TRUE),
    mean_prediction_accuracy = mean(prediction_accuracy, na.rm = TRUE),
    action_success_rate = mean(action_success, na.rm = TRUE),
    mean_explanation = mean(explanation_score, na.rm = TRUE),
    mean_human_trust = mean(human_trust, na.rm = TRUE),
    override_rate = mean(override_decision, na.rm = TRUE),
    mean_calibration_error = mean(calibration_error, na.rm = TRUE),
    mean_response_time_ms = mean(response_time_ms, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(architecture_summary, file.path(output_dir, "r_summary_by_architecture.csv"))

prediction_model <- lmer(
  prediction_accuracy ~
    architecture +
    task_condition +
    input_noise +
    representation_quality +
    working_memory_load +
    retrieval_latency_ms +
    uncertainty_level +
    policy_entropy +
    (1 | agent_id),
  data = dat,
  REML = FALSE
)

success_model <- glmer(
  action_success ~
    architecture +
    task_condition +
    input_noise +
    representation_quality +
    working_memory_load +
    retrieval_latency_ms +
    uncertainty_level +
    policy_entropy +
    prediction_accuracy +
    (1 | agent_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

explanation_model <- lmer(
  explanation_score ~
    architecture +
    task_condition +
    representation_quality +
    uncertainty_level +
    policy_entropy +
    calibration_error +
    (1 | agent_id),
  data = dat,
  REML = FALSE
)

override_model <- glmer(
  override_decision ~
    architecture +
    task_condition +
    explanation_score +
    human_trust +
    calibration_error +
    uncertainty_level +
    action_success +
    (1 | agent_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

rt_model <- lmer(
  log_response_time ~
    architecture +
    task_condition +
    retrieval_latency_ms +
    working_memory_load +
    uncertainty_level +
    policy_entropy +
    (1 | agent_id),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    prediction_model = summary(prediction_model),
    success_model = summary(success_model),
    explanation_model = summary(explanation_model),
    override_model = summary(override_model),
    response_time_model = summary(rt_model),
    architecture_prediction = emmeans(prediction_model, ~ architecture),
    architecture_success = emmeans(success_model, ~ architecture, type = "response"),
    architecture_explanation = emmeans(explanation_model, ~ architecture)
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(prediction_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_prediction_model_coefficients.csv"))
write_csv(tidy(success_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_success_model_coefficients.csv"))
write_csv(tidy(explanation_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_explanation_model_coefficients.csv"))
write_csv(tidy(override_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_override_model_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_model_coefficients.csv"))

p <- ggplot(dat, aes(x = uncertainty_level, y = prediction_accuracy, color = architecture)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Architecture performance under uncertainty",
    x = "Uncertainty level",
    y = "Prediction accuracy"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_uncertainty_prediction_accuracy.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
