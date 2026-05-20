#!/usr/bin/env Rscript

# Analogical reasoning and knowledge transfer.
# Hierarchical and descriptive workflow for cognitive psychologists,
# learning scientists, AI researchers, and education researchers.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/analogical_reasoning_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    condition = factor(condition),
    source_id = factor(source_id),
    target_id = factor(target_id),
    analogical_cue = as.integer(analogical_cue),
    mapping_accuracy = as.integer(mapping_accuracy),
    transfer_success = as.integer(transfer_success),
    log_response_time = log(response_time_ms)
  )

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    mean_source_familiarity = mean(source_familiarity, na.rm = TRUE),
    mean_target_novelty = mean(target_novelty, na.rm = TRUE),
    mean_surface_similarity = mean(surface_similarity, na.rm = TRUE),
    mean_structural_similarity = mean(structural_similarity, na.rm = TRUE),
    mean_relational_complexity = mean(relational_complexity, na.rm = TRUE),
    mean_working_memory_load = mean(working_memory_load, na.rm = TRUE),
    analogical_cue_rate = mean(analogical_cue, na.rm = TRUE),
    mapping_accuracy_rate = mean(mapping_accuracy, na.rm = TRUE),
    transfer_success_rate = mean(transfer_success, na.rm = TRUE),
    mean_inference_quality = mean(inference_quality, na.rm = TRUE),
    mean_schema_abstraction = mean(schema_abstraction, na.rm = TRUE),
    mean_confidence = mean(confidence, na.rm = TRUE),
    mean_response_time_ms = mean(response_time_ms, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

mapping_model <- glmer(
  mapping_accuracy ~
    condition +
    source_familiarity +
    target_novelty +
    surface_similarity +
    structural_similarity +
    relational_complexity +
    working_memory_load +
    analogical_cue +
    (1 | participant) +
    (1 | target_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

transfer_model <- glmer(
  transfer_success ~
    condition +
    source_familiarity +
    target_novelty +
    surface_similarity +
    structural_similarity +
    relational_complexity +
    working_memory_load +
    analogical_cue +
    mapping_accuracy +
    (1 | participant) +
    (1 | target_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

quality_model <- lmer(
  inference_quality ~
    condition +
    structural_similarity +
    surface_similarity +
    relational_complexity +
    working_memory_load +
    mapping_accuracy +
    transfer_success +
    schema_abstraction +
    (1 | participant) +
    (1 | target_id),
  data = dat,
  REML = FALSE
)

schema_model <- lmer(
  schema_abstraction ~
    condition +
    source_familiarity +
    structural_similarity +
    surface_similarity +
    mapping_accuracy +
    transfer_success +
    relational_complexity +
    (1 | participant) +
    (1 | target_id),
  data = dat,
  REML = FALSE
)

rt_model <- lmer(
  log_response_time ~
    condition +
    relational_complexity +
    working_memory_load +
    source_familiarity +
    target_novelty +
    structural_similarity +
    analogical_cue +
    (1 | participant) +
    (1 | target_id),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    mapping_model = summary(mapping_model),
    transfer_model = summary(transfer_model),
    inference_quality_model = summary(quality_model),
    schema_abstraction_model = summary(schema_model),
    response_time_model = summary(rt_model),
    condition_mapping = emmeans(mapping_model, ~ condition, type = "response"),
    condition_transfer = emmeans(transfer_model, ~ condition, type = "response"),
    condition_quality = emmeans(quality_model, ~ condition)
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(mapping_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_mapping_model_coefficients.csv"))
write_csv(tidy(transfer_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_transfer_model_coefficients.csv"))
write_csv(tidy(quality_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_inference_quality_coefficients.csv"))
write_csv(tidy(schema_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_schema_abstraction_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_coefficients.csv"))

p <- ggplot(dat, aes(x = structural_similarity, y = inference_quality, color = condition)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Structural similarity and analogical inference quality",
    x = "Structural similarity",
    y = "Inference quality"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_structural_similarity_inference_quality.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
