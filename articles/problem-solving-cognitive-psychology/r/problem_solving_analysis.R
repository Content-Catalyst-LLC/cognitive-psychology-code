#!/usr/bin/env Rscript

# Problem solving in cognitive psychology.
# Hierarchical and descriptive workflow for cognitive psychologists,
# learning scientists, human factors researchers, and decision scientists.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/problem_solving_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    condition = factor(condition),
    problem_id = factor(problem_id),
    strategy_type = factor(strategy_type),
    switched_strategy = as.integer(switched_strategy),
    insight_event = as.integer(insight_event),
    solution_accuracy = as.integer(solution_accuracy),
    log_response_time = log(response_time_ms)
  )

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    mean_difficulty = mean(problem_difficulty, na.rm = TRUE),
    mean_representation = mean(representation_quality, na.rm = TRUE),
    mean_goal_clarity = mean(goal_clarity, na.rm = TRUE),
    mean_constraint_load = mean(constraint_load, na.rm = TRUE),
    mean_wm_load = mean(wm_load, na.rm = TRUE),
    mean_metacognition = mean(metacognitive_monitoring, na.rm = TRUE),
    switch_rate = mean(switched_strategy, na.rm = TRUE),
    mean_switch_count = mean(strategy_switch_count, na.rm = TRUE),
    insight_rate = mean(insight_event, na.rm = TRUE),
    accuracy_rate = mean(solution_accuracy, na.rm = TRUE),
    mean_solution_quality = mean(solution_quality, na.rm = TRUE),
    mean_errors = mean(error_count, na.rm = TRUE),
    mean_confidence = mean(confidence, na.rm = TRUE),
    mean_response_time_ms = mean(response_time_ms, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

accuracy_model <- glmer(
  solution_accuracy ~
    condition +
    strategy_type +
    problem_difficulty +
    representation_quality +
    goal_clarity +
    constraint_load +
    wm_load +
    metacognitive_monitoring +
    switched_strategy +
    insight_event +
    (1 | participant) +
    (1 | problem_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

switch_model <- glmer(
  switched_strategy ~
    condition +
    problem_difficulty +
    representation_quality +
    constraint_load +
    wm_load +
    metacognitive_monitoring +
    (1 | participant) +
    (1 | problem_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

quality_model <- lmer(
  solution_quality ~
    condition +
    strategy_type +
    problem_difficulty +
    representation_quality +
    goal_clarity +
    constraint_load +
    wm_load +
    metacognitive_monitoring +
    insight_event +
    solution_accuracy +
    error_count +
    (1 | participant) +
    (1 | problem_id),
  data = dat,
  REML = FALSE
)

rt_model <- lmer(
  log_response_time ~
    condition +
    strategy_type +
    problem_difficulty +
    representation_quality +
    constraint_load +
    wm_load +
    strategy_switch_count +
    solution_accuracy +
    (1 | participant) +
    (1 | problem_id),
  data = dat,
  REML = FALSE
)

error_model <- glmer(
  error_count ~
    condition +
    strategy_type +
    problem_difficulty +
    representation_quality +
    constraint_load +
    wm_load +
    metacognitive_monitoring +
    (1 | participant) +
    (1 | problem_id),
  data = dat,
  family = poisson(),
  control = glmerControl(optimizer = "bobyqa")
)

capture.output(
  list(
    accuracy_model = summary(accuracy_model),
    strategy_switch_model = summary(switch_model),
    solution_quality_model = summary(quality_model),
    response_time_model = summary(rt_model),
    error_count_model = summary(error_model),
    condition_accuracy = emmeans(accuracy_model, ~ condition, type = "response"),
    strategy_accuracy = emmeans(accuracy_model, ~ strategy_type, type = "response"),
    condition_quality = emmeans(quality_model, ~ condition)
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(accuracy_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_accuracy_model_coefficients.csv"))
write_csv(tidy(switch_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_switch_model_coefficients.csv"))
write_csv(tidy(quality_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_solution_quality_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_coefficients.csv"))
write_csv(tidy(error_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_error_model_coefficients.csv"))

p <- ggplot(dat, aes(x = representation_quality, y = solution_quality, color = strategy_type)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Problem representation and solution quality",
    x = "Representation quality",
    y = "Solution quality"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_representation_solution_quality.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
