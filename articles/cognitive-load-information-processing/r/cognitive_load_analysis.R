#!/usr/bin/env Rscript

# Cognitive load and information processing.
# Hierarchical workflow for intrinsic load, extraneous load, germane processing,
# working-memory capacity, prior knowledge, design quality, performance, transfer,
# response time, and mental efficiency.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/cognitive_load_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    condition = factor(condition),
    domain = factor(domain),
    task_id = factor(task_id),
    expertise_level = factor(expertise_level, levels = c("novice", "intermediate", "advanced", "expert")),
    correct = as.integer(correct),
    total_load = intrinsic_load + extraneous_load + germane_load,
    effective_load = intrinsic_load + extraneous_load - 0.25 * prior_knowledge,
    overload_margin = working_memory_capacity + 0.45 * prior_knowledge -
      (intrinsic_load + extraneous_load + 0.55 * germane_load),
    log_rt = log(rt_ms)
  )

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    mean_intrinsic = mean(intrinsic_load, na.rm = TRUE),
    mean_extraneous = mean(extraneous_load, na.rm = TRUE),
    mean_germane = mean(germane_load, na.rm = TRUE),
    mean_total_load = mean(total_load, na.rm = TRUE),
    mean_effort = mean(subjective_effort, na.rm = TRUE),
    mean_mental_demand = mean(mental_demand, na.rm = TRUE),
    mean_frustration = mean(frustration, na.rm = TRUE),
    accuracy = mean(performance_accuracy, na.rm = TRUE),
    correct_rate = mean(correct, na.rm = TRUE),
    mean_rt_ms = mean(rt_ms, na.rm = TRUE),
    mean_transfer = mean(transfer_score, na.rm = TRUE),
    mean_learning_gain = mean(learning_gain, na.rm = TRUE),
    mean_efficiency = mean(mental_efficiency, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

expertise_summary <- dat %>%
  group_by(expertise_level, condition) %>%
  summarise(
    n_trials = n(),
    correct_rate = mean(correct, na.rm = TRUE),
    mean_effort = mean(subjective_effort, na.rm = TRUE),
    mean_transfer = mean(transfer_score, na.rm = TRUE),
    mean_efficiency = mean(mental_efficiency, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(expertise_summary, file.path(output_dir, "r_summary_by_expertise_condition.csv"))

correct_model <- glmer(
  correct ~
    condition +
    domain +
    expertise_level +
    intrinsic_load +
    extraneous_load +
    germane_load +
    element_interactivity +
    prior_knowledge +
    working_memory_capacity +
    design_quality +
    split_attention +
    redundancy +
    subjective_effort +
    (1 | participant) +
    (1 | task_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

accuracy_model <- lmer(
  performance_accuracy ~
    condition +
    domain +
    expertise_level +
    intrinsic_load +
    extraneous_load +
    germane_load +
    prior_knowledge +
    working_memory_capacity +
    design_quality +
    split_attention +
    redundancy +
    mental_demand +
    frustration +
    (1 | participant) +
    (1 | task_id),
  data = dat,
  REML = FALSE
)

effort_model <- lmer(
  subjective_effort ~
    condition +
    domain +
    expertise_level +
    intrinsic_load +
    extraneous_load +
    germane_load +
    element_interactivity +
    prior_knowledge +
    design_quality +
    split_attention +
    redundancy +
    (1 | participant) +
    (1 | task_id),
  data = dat,
  REML = FALSE
)

transfer_model <- lmer(
  transfer_score ~
    condition +
    domain +
    expertise_level +
    germane_load +
    extraneous_load +
    intrinsic_load +
    prior_knowledge +
    design_quality +
    performance_accuracy +
    subjective_effort +
    (1 | participant) +
    (1 | task_id),
  data = dat,
  REML = FALSE
)

efficiency_model <- lmer(
  mental_efficiency ~
    condition +
    domain +
    expertise_level +
    intrinsic_load +
    extraneous_load +
    germane_load +
    prior_knowledge +
    design_quality +
    split_attention +
    redundancy +
    (1 | participant) +
    (1 | task_id),
  data = dat,
  REML = FALSE
)

rt_model <- lmer(
  log_rt ~
    condition +
    domain +
    expertise_level +
    intrinsic_load +
    extraneous_load +
    germane_load +
    prior_knowledge +
    design_quality +
    temporal_demand +
    correct +
    confidence +
    (1 | participant) +
    (1 | task_id),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    correct_model = summary(correct_model),
    accuracy_model = summary(accuracy_model),
    effort_model = summary(effort_model),
    transfer_model = summary(transfer_model),
    efficiency_model = summary(efficiency_model),
    response_time_model = summary(rt_model),
    condition_accuracy = emmeans(correct_model, ~ condition, type = "response"),
    condition_effort = emmeans(effort_model, ~ condition),
    expertise_by_condition_accuracy = emmeans(correct_model, ~ condition | expertise_level, type = "response")
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(correct_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_correct_coefficients.csv"))
write_csv(tidy(accuracy_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_accuracy_coefficients.csv"))
write_csv(tidy(effort_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_effort_coefficients.csv"))
write_csv(tidy(transfer_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_transfer_coefficients.csv"))
write_csv(tidy(efficiency_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_efficiency_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_coefficients.csv"))

p <- ggplot(dat, aes(x = intrinsic_load + extraneous_load, y = performance_accuracy, color = condition)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Load demand and performance accuracy",
    x = "Intrinsic + extraneous load",
    y = "Performance accuracy"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_load_performance_accuracy.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
