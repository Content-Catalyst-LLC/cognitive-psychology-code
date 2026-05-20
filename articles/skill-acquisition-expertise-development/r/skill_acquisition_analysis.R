#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)
input_path <- ifelse(length(args) >= 1, args[[1]], "data/skill_acquisition_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    expertise_level = factor(expertise_level, levels = c("novice", "intermediate", "advanced", "expert")),
    condition = factor(condition),
    domain = factor(domain),
    task_id = factor(task_id),
    log_response_time = log(response_time_ms)
  )

learning_curve <- dat %>%
  group_by(expertise_level, session) %>%
  summarise(
    mean_accuracy = mean(accuracy, na.rm = TRUE),
    mean_error_rate = mean(error_rate, na.rm = TRUE),
    mean_response_time_ms = mean(response_time_ms, na.rm = TRUE),
    mean_automaticity = mean(automaticity_score, na.rm = TRUE),
    .groups = "drop"
  )
write_csv(learning_curve, file.path(output_dir, "r_learning_curve.csv"))

accuracy_model <- lmer(
  accuracy ~ session * expertise_level + condition + domain +
    deliberate_practice_quality + feedback_quality + task_difficulty +
    chunking_score + pattern_recognition_score + strategy_quality + cognitive_load +
    (1 + session | participant) + (1 | task_id),
  data = dat,
  REML = FALSE
)

error_model <- lmer(
  error_rate ~ session * expertise_level + condition + domain +
    deliberate_practice_quality + feedback_quality + task_difficulty + cognitive_load +
    (1 + session | participant) + (1 | task_id),
  data = dat,
  REML = FALSE
)

rt_model <- lmer(
  log_response_time ~ session * expertise_level + condition + domain +
    accuracy + task_difficulty + cognitive_load + working_memory_demand +
    chunking_score + pattern_recognition_score +
    (1 + session | participant) + (1 | task_id),
  data = dat,
  REML = FALSE
)

transfer_model <- lmer(
  transfer_score ~ session + expertise_level + condition + domain +
    deliberate_practice_quality + feedback_quality + strategy_quality +
    pattern_recognition_score + adaptive_flexibility + accuracy +
    (1 | participant) + (1 | task_id),
  data = dat,
  REML = FALSE
)

automaticity_model <- lmer(
  automaticity_score ~ session + expertise_level + condition + accuracy +
    chunking_score + pattern_recognition_score + cognitive_load + working_memory_demand +
    (1 | participant) + (1 | task_id),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    accuracy_model = summary(accuracy_model),
    error_model = summary(error_model),
    response_time_model = summary(rt_model),
    transfer_model = summary(transfer_model),
    automaticity_model = summary(automaticity_model),
    expertise_accuracy = emmeans(accuracy_model, ~ expertise_level),
    condition_transfer = emmeans(transfer_model, ~ condition)
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(accuracy_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_accuracy_coefficients.csv"))
write_csv(tidy(error_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_error_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_coefficients.csv"))
write_csv(tidy(transfer_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_transfer_coefficients.csv"))
write_csv(tidy(automaticity_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_automaticity_coefficients.csv"))

p <- ggplot(learning_curve, aes(x = session, y = mean_accuracy, color = expertise_level)) +
  geom_point() +
  geom_line() +
  labs(title = "Skill acquisition across practice sessions", x = "Practice session", y = "Mean accuracy") +
  theme_minimal(base_size = 12)

ggsave(file.path(output_dir, "r_learning_curve_accuracy.png"), p, width = 9, height = 6, dpi = 300)
message("R analysis complete. Outputs written to: ", output_dir)
