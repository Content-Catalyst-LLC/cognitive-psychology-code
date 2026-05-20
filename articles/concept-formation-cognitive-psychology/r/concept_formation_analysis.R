#!/usr/bin/env Rscript

# Concept formation in cognitive psychology.
# Hierarchical and descriptive workflow for cognitive psychologists,
# learning scientists, psycholinguists, and category-learning researchers.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/concept_formation_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    condition = factor(condition),
    stimulus_id = factor(stimulus_id),
    category_label = factor(category_label),
    feedback_available = as.integer(feedback_available),
    category_accuracy = as.integer(category_accuracy),
    log_response_time = log(response_time_ms)
  )

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    mean_prototype_distance = mean(prototype_distance, na.rm = TRUE),
    mean_competing_distance = mean(nearest_competing_distance, na.rm = TRUE),
    mean_exemplar_similarity = mean(exemplar_similarity, na.rm = TRUE),
    mean_feature_diagnosticity = mean(feature_diagnosticity, na.rm = TRUE),
    mean_boundary_ambiguity = mean(boundary_ambiguity, na.rm = TRUE),
    mean_rule_consistency = mean(rule_consistency, na.rm = TRUE),
    feedback_rate = mean(feedback_available, na.rm = TRUE),
    accuracy_rate = mean(category_accuracy, na.rm = TRUE),
    mean_generalization = mean(generalization_score, na.rm = TRUE),
    mean_discrimination = mean(discrimination_score, na.rm = TRUE),
    mean_abstraction_quality = mean(abstraction_quality, na.rm = TRUE),
    mean_conceptual_flexibility = mean(conceptual_flexibility, na.rm = TRUE),
    mean_confidence = mean(confidence, na.rm = TRUE),
    mean_response_time_ms = mean(response_time_ms, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

accuracy_model <- glmer(
  category_accuracy ~
    condition +
    category_label +
    prototype_distance +
    nearest_competing_distance +
    exemplar_similarity +
    feature_diagnosticity +
    feature_overlap +
    boundary_ambiguity +
    rule_consistency +
    feedback_available +
    (1 | participant) +
    (1 | stimulus_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

generalization_model <- lmer(
  generalization_score ~
    condition +
    prototype_distance +
    exemplar_similarity +
    feature_diagnosticity +
    boundary_ambiguity +
    rule_consistency +
    category_accuracy +
    abstraction_quality +
    conceptual_flexibility +
    (1 | participant) +
    (1 | stimulus_id),
  data = dat,
  REML = FALSE
)

discrimination_model <- lmer(
  discrimination_score ~
    condition +
    prototype_distance +
    nearest_competing_distance +
    feature_diagnosticity +
    boundary_ambiguity +
    rule_consistency +
    category_accuracy +
    (1 | participant) +
    (1 | stimulus_id),
  data = dat,
  REML = FALSE
)

abstraction_model <- lmer(
  abstraction_quality ~
    condition +
    feature_diagnosticity +
    rule_consistency +
    feedback_available +
    category_accuracy +
    boundary_ambiguity +
    prototype_distance +
    (1 | participant) +
    (1 | stimulus_id),
  data = dat,
  REML = FALSE
)

rt_model <- lmer(
  log_response_time ~
    condition +
    prototype_distance +
    boundary_ambiguity +
    exemplar_similarity +
    feature_diagnosticity +
    rule_consistency +
    category_accuracy +
    (1 | participant) +
    (1 | stimulus_id),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    accuracy_model = summary(accuracy_model),
    generalization_model = summary(generalization_model),
    discrimination_model = summary(discrimination_model),
    abstraction_quality_model = summary(abstraction_model),
    response_time_model = summary(rt_model),
    condition_accuracy = emmeans(accuracy_model, ~ condition, type = "response"),
    condition_generalization = emmeans(generalization_model, ~ condition),
    condition_discrimination = emmeans(discrimination_model, ~ condition)
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(accuracy_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_accuracy_model_coefficients.csv"))
write_csv(tidy(generalization_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_generalization_coefficients.csv"))
write_csv(tidy(discrimination_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_discrimination_coefficients.csv"))
write_csv(tidy(abstraction_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_abstraction_quality_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_coefficients.csv"))

p <- ggplot(dat, aes(x = prototype_distance, y = generalization_score, color = condition)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Prototype distance and conceptual generalization",
    x = "Prototype distance",
    y = "Generalization score"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_prototype_distance_generalization.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
