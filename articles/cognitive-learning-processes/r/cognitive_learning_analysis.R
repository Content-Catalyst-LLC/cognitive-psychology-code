#!/usr/bin/env Rscript

# Cognitive learning processes.
# Hierarchical workflow for learning curves, retrieval practice, cognitive load,
# transfer, retention, schema formation, and adaptive application.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/cognitive_learning_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    condition = factor(condition),
    domain = factor(domain),
    item_id = factor(item_id),
    retrieval_practice = as.integer(retrieval_practice),
    log_response_time = log(response_time_ms)
  )

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    mean_prior_knowledge = mean(prior_knowledge, na.rm = TRUE),
    mean_attention = mean(attention_score, na.rm = TRUE),
    mean_encoding = mean(encoding_quality, na.rm = TRUE),
    mean_schema_strength = mean(schema_strength, na.rm = TRUE),
    retrieval_rate = mean(retrieval_practice, na.rm = TRUE),
    mean_feedback = mean(feedback_quality, na.rm = TRUE),
    mean_cognitive_load = mean(cognitive_load, na.rm = TRUE),
    mean_comprehension = mean(comprehension_score, na.rm = TRUE),
    mean_accuracy = mean(accuracy, na.rm = TRUE),
    mean_transfer = mean(transfer_score, na.rm = TRUE),
    mean_retention = mean(retention_score, na.rm = TRUE),
    mean_response_time_ms = mean(response_time_ms, na.rm = TRUE),
    mean_learning_gain = mean(learning_gain, na.rm = TRUE),
    mean_adaptive_application = mean(adaptive_application, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

learning_curve <- dat %>%
  group_by(condition, session) %>%
  summarise(
    mean_accuracy = mean(accuracy, na.rm = TRUE),
    mean_comprehension = mean(comprehension_score, na.rm = TRUE),
    mean_transfer = mean(transfer_score, na.rm = TRUE),
    mean_retention = mean(retention_score, na.rm = TRUE),
    mean_cognitive_load = mean(cognitive_load, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(learning_curve, file.path(output_dir, "r_learning_curve.csv"))

comprehension_model <- lmer(
  comprehension_score ~
    session * condition +
    domain +
    prior_knowledge +
    attention_score +
    encoding_quality +
    working_memory_load +
    schema_strength +
    retrieval_practice +
    feedback_quality +
    cognitive_load +
    (1 + session | participant) +
    (1 | item_id),
  data = dat,
  REML = FALSE
)

accuracy_model <- lmer(
  accuracy ~
    session * condition +
    domain +
    prior_knowledge +
    attention_score +
    encoding_quality +
    schema_strength +
    retrieval_practice +
    feedback_quality +
    cognitive_load +
    (1 + session | participant) +
    (1 | item_id),
  data = dat,
  REML = FALSE
)

transfer_model <- lmer(
  transfer_score ~
    session * condition +
    domain +
    prior_knowledge +
    schema_strength +
    retrieval_practice +
    feedback_quality +
    comprehension_score +
    cognitive_load +
    (1 + session | participant) +
    (1 | item_id),
  data = dat,
  REML = FALSE
)

retention_model <- lmer(
  retention_score ~
    session * condition +
    domain +
    retrieval_practice +
    feedback_quality +
    schema_strength +
    comprehension_score +
    cognitive_load +
    (1 + session | participant) +
    (1 | item_id),
  data = dat,
  REML = FALSE
)

rt_model <- lmer(
  log_response_time ~
    session * condition +
    domain +
    comprehension_score +
    schema_strength +
    cognitive_load +
    working_memory_load +
    accuracy +
    (1 + session | participant) +
    (1 | item_id),
  data = dat,
  REML = FALSE
)

adaptive_model <- lmer(
  adaptive_application ~
    session +
    condition +
    domain +
    schema_strength +
    transfer_score +
    feedback_quality +
    retrieval_practice +
    cognitive_load +
    (1 | participant) +
    (1 | item_id),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    comprehension_model = summary(comprehension_model),
    accuracy_model = summary(accuracy_model),
    transfer_model = summary(transfer_model),
    retention_model = summary(retention_model),
    response_time_model = summary(rt_model),
    adaptive_application_model = summary(adaptive_model),
    condition_comprehension = emmeans(comprehension_model, ~ condition),
    condition_transfer = emmeans(transfer_model, ~ condition),
    condition_retention = emmeans(retention_model, ~ condition)
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(comprehension_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_comprehension_coefficients.csv"))
write_csv(tidy(accuracy_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_accuracy_coefficients.csv"))
write_csv(tidy(transfer_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_transfer_coefficients.csv"))
write_csv(tidy(retention_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_retention_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_coefficients.csv"))
write_csv(tidy(adaptive_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_adaptive_application_coefficients.csv"))

p <- ggplot(learning_curve, aes(x = session, y = mean_accuracy, color = condition)) +
  geom_point() +
  geom_line() +
  labs(
    title = "Cognitive learning performance across sessions",
    x = "Learning session",
    y = "Mean accuracy"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_learning_curve_accuracy.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
