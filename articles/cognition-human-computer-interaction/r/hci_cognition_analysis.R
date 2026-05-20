#!/usr/bin/env Rscript

# Cognition in human-computer interaction.
# Hierarchical and descriptive workflow for cognitive psychologists,
# HCI researchers, usability researchers, and human factors specialists.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/hci_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    interface_condition = factor(interface_condition),
    task_id = factor(task_id),
    success = as.integer(success),
    warning_detected = as.integer(warning_detected),
    log_response_time = log(response_time_ms)
  )

condition_summary <- dat %>%
  group_by(interface_condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    mean_task_difficulty = mean(task_difficulty, na.rm = TRUE),
    mean_perceptual_load = mean(perceptual_load, na.rm = TRUE),
    mean_attention = mean(attentional_demand, na.rm = TRUE),
    mean_working_memory = mean(working_memory_load, na.rm = TRUE),
    mean_cognitive_load = mean(cognitive_load, na.rm = TRUE),
    mean_alignment = mean(alignment_score, na.rm = TRUE),
    mean_trust = mean(trust_score, na.rm = TRUE),
    mean_accessibility_friction = mean(accessibility_friction, na.rm = TRUE),
    success_rate = mean(success, na.rm = TRUE),
    warning_detection_rate = mean(warning_detected, na.rm = TRUE),
    mean_errors = mean(error_count, na.rm = TRUE),
    mean_response_time_ms = mean(response_time_ms, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_interface_condition.csv"))

success_model <- glmer(
  success ~
    interface_condition +
    task_difficulty +
    perceptual_load +
    attentional_demand +
    working_memory_load +
    cognitive_load +
    alignment_score +
    trust_score +
    accessibility_friction +
    (1 | participant),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

rt_model <- lmer(
  log_response_time ~
    interface_condition +
    task_difficulty +
    perceptual_load +
    attentional_demand +
    working_memory_load +
    cognitive_load +
    alignment_score +
    accessibility_friction +
    (1 | participant),
  data = dat,
  REML = FALSE
)

error_model <- glmer(
  error_count ~
    interface_condition +
    task_difficulty +
    perceptual_load +
    attentional_demand +
    working_memory_load +
    cognitive_load +
    alignment_score +
    accessibility_friction +
    (1 | participant),
  data = dat,
  family = poisson(),
  control = glmerControl(optimizer = "bobyqa")
)

warning_model <- glmer(
  warning_detected ~
    interface_condition +
    perceptual_load +
    attentional_demand +
    cognitive_load +
    alignment_score +
    trust_score +
    (1 | participant),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

capture.output(
  list(
    success_model = summary(success_model),
    response_time_model = summary(rt_model),
    error_model = summary(error_model),
    warning_detection_model = summary(warning_model),
    condition_success = emmeans(success_model, ~ interface_condition, type = "response"),
    condition_rt = emmeans(rt_model, ~ interface_condition),
    condition_errors = emmeans(error_model, ~ interface_condition, type = "response")
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(success_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_success_model_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_model_coefficients.csv"))
write_csv(tidy(error_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_error_model_coefficients.csv"))
write_csv(tidy(warning_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_warning_detection_coefficients.csv"))

p <- ggplot(dat, aes(x = cognitive_load, y = error_count, color = interface_condition)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "glm", method.args = list(family = "poisson"), se = FALSE) +
  labs(
    title = "Cognitive load and interaction error",
    x = "Cognitive load",
    y = "Error count"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_cognitive_load_error_count.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
