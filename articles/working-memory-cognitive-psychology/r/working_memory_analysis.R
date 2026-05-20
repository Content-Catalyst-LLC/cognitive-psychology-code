#!/usr/bin/env Rscript

# Working memory in cognitive psychology.
# Hierarchical workflow for span, updating, load, interference,
# attentional control, cognitive load, response time, and capacity estimates.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/working_memory_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    condition = factor(condition),
    domain = factor(domain),
    task_type = factor(task_type),
    modality = factor(modality),
    correct = as.integer(correct),
    log_rt = log(response_time_ms)
  )

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    mean_load = mean(load, na.rm = TRUE),
    correct_rate = mean(correct, na.rm = TRUE),
    mean_accuracy = mean(accuracy, na.rm = TRUE),
    mean_response_time_ms = mean(response_time_ms, na.rm = TRUE),
    mean_span_score = mean(span_score, na.rm = TRUE),
    mean_updating_score = mean(updating_score, na.rm = TRUE),
    mean_capacity_estimate = mean(capacity_estimate, na.rm = TRUE),
    mean_overload_probability = mean(overload_probability, na.rm = TRUE),
    mean_dual_task_cost = mean(dual_task_cost, na.rm = TRUE),
    mean_cognitive_load = mean(cognitive_load, na.rm = TRUE),
    mean_confidence = mean(confidence, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

task_summary <- dat %>%
  group_by(task_type) %>%
  summarise(
    n_trials = n(),
    correct_rate = mean(correct, na.rm = TRUE),
    mean_accuracy = mean(accuracy, na.rm = TRUE),
    mean_response_time_ms = mean(response_time_ms, na.rm = TRUE),
    mean_span_score = mean(span_score, na.rm = TRUE),
    mean_updating_score = mean(updating_score, na.rm = TRUE),
    mean_capacity_estimate = mean(capacity_estimate, na.rm = TRUE),
    mean_cognitive_load = mean(cognitive_load, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(task_summary, file.path(output_dir, "r_summary_by_task_type.csv"))

accuracy_model <- glmer(
  correct ~
    condition +
    task_type +
    modality +
    load +
    serial_position +
    distractor_level +
    interference +
    attentional_control +
    updating_demand +
    storage_demand +
    processing_demand +
    chunking_support +
    rehearsal_opportunity +
    cognitive_load +
    learning_support +
    interface_complexity +
    (1 + load | participant),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

capacity_model <- lmer(
  capacity_estimate ~
    condition +
    task_type +
    modality +
    load +
    interference +
    attentional_control +
    chunking_support +
    rehearsal_opportunity +
    cognitive_load +
    learning_support +
    interface_complexity +
    (1 + load | participant),
  data = dat,
  REML = FALSE
)

updating_model <- lmer(
  updating_score ~
    condition +
    task_type +
    modality +
    load +
    updating_demand +
    attentional_control +
    interference +
    cognitive_load +
    chunking_support +
    rehearsal_opportunity +
    (1 + load | participant),
  data = dat,
  REML = FALSE
)

overload_model <- lmer(
  overload_probability ~
    condition +
    task_type +
    load +
    capacity_estimate +
    interference +
    cognitive_load +
    attentional_control +
    learning_support +
    interface_complexity +
    (1 + load | participant),
  data = dat,
  REML = FALSE
)

rt_model <- lmer(
  log_rt ~
    condition +
    task_type +
    modality +
    load +
    updating_demand +
    processing_demand +
    interference +
    cognitive_load +
    attentional_control +
    correct +
    confidence +
    (1 + load | participant),
  data = dat,
  REML = FALSE
)

confidence_model <- lmer(
  confidence ~
    condition +
    task_type +
    modality +
    accuracy +
    capacity_estimate +
    overload_probability +
    cognitive_load +
    attentional_control +
    interference +
    learning_support +
    (1 + load | participant),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    accuracy_model = summary(accuracy_model),
    capacity_model = summary(capacity_model),
    updating_model = summary(updating_model),
    overload_model = summary(overload_model),
    response_time_model = summary(rt_model),
    confidence_model = summary(confidence_model),
    accuracy_by_condition = emmeans(accuracy_model, ~ condition, type = "response"),
    accuracy_by_task = emmeans(accuracy_model, ~ task_type, type = "response"),
    capacity_by_condition = emmeans(capacity_model, ~ condition)
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(accuracy_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_accuracy_coefficients.csv"))
write_csv(tidy(capacity_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_capacity_coefficients.csv"))
write_csv(tidy(updating_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_updating_coefficients.csv"))
write_csv(tidy(overload_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_overload_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_coefficients.csv"))
write_csv(tidy(confidence_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_confidence_coefficients.csv"))

p <- ggplot(dat, aes(x = load, y = accuracy, color = condition)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "glm", method.args = list(family = "binomial"), se = FALSE) +
  labs(
    title = "Working-memory accuracy across load",
    x = "Memory load",
    y = "Accuracy"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_accuracy_by_load.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
