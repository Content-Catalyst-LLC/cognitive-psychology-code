#!/usr/bin/env Rscript

# Semantic memory in cognitive psychology.
# Hierarchical and descriptive workflow for cognitive psychologists,
# psycholinguists, memory researchers, and cognitive neuroscientists.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/semantic_memory_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    condition = factor(condition),
    cue_concept = factor(cue_concept),
    target_concept = factor(target_concept),
    category = factor(category),
    relation_type = factor(relation_type),
    fact_true = as.integer(fact_true),
    false_association = as.integer(false_association),
    verification_accuracy = as.integer(verification_accuracy),
    log_response_time = log(response_time_ms)
  )

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    mean_semantic_distance = mean(semantic_distance, na.rm = TRUE),
    mean_category_typicality = mean(category_typicality, na.rm = TRUE),
    mean_feature_overlap = mean(feature_overlap, na.rm = TRUE),
    mean_associative_strength = mean(associative_strength, na.rm = TRUE),
    mean_concept_familiarity = mean(concept_familiarity, na.rm = TRUE),
    mean_schema_consistency = mean(schema_consistency, na.rm = TRUE),
    false_association_rate = mean(false_association, na.rm = TRUE),
    true_fact_rate = mean(fact_true, na.rm = TRUE),
    accuracy_rate = mean(verification_accuracy, na.rm = TRUE),
    mean_category_strength = mean(category_strength, na.rm = TRUE),
    mean_confidence = mean(confidence, na.rm = TRUE),
    mean_response_time_ms = mean(response_time_ms, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

accuracy_model <- glmer(
  verification_accuracy ~
    condition +
    relation_type +
    semantic_distance +
    fact_true +
    category_typicality +
    feature_overlap +
    associative_strength +
    concept_familiarity +
    schema_consistency +
    false_association +
    (1 | participant) +
    (1 | target_concept),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

rt_model <- lmer(
  log_response_time ~
    condition +
    relation_type +
    semantic_distance +
    fact_true +
    category_typicality +
    associative_strength +
    concept_familiarity +
    false_association +
    verification_accuracy +
    (1 | participant) +
    (1 | target_concept),
  data = dat,
  REML = FALSE
)

category_model <- lmer(
  category_strength ~
    condition +
    semantic_distance +
    category_typicality +
    feature_overlap +
    associative_strength +
    schema_consistency +
    false_association +
    (1 | participant) +
    (1 | target_concept),
  data = dat,
  REML = FALSE
)

confidence_model <- lmer(
  confidence ~
    verification_accuracy +
    category_strength +
    concept_familiarity +
    false_association +
    semantic_distance +
    condition +
    (1 | participant) +
    (1 | target_concept),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    accuracy_model = summary(accuracy_model),
    response_time_model = summary(rt_model),
    category_strength_model = summary(category_model),
    confidence_model = summary(confidence_model),
    condition_accuracy = emmeans(accuracy_model, ~ condition, type = "response"),
    relation_accuracy = emmeans(accuracy_model, ~ relation_type, type = "response"),
    condition_rt = emmeans(rt_model, ~ condition),
    condition_category_strength = emmeans(category_model, ~ condition)
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(accuracy_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_accuracy_model_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_coefficients.csv"))
write_csv(tidy(category_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_category_strength_coefficients.csv"))
write_csv(tidy(confidence_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_confidence_coefficients.csv"))

p <- ggplot(dat, aes(x = semantic_distance, y = response_time_ms, color = relation_type)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Semantic distance and retrieval latency",
    x = "Semantic distance",
    y = "Response time (ms)"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_semantic_distance_response_time.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
