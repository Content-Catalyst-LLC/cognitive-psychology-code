#!/usr/bin/env Rscript

# Language processing in cognitive psychology.
# Hierarchical and descriptive workflow for cognitive psychologists,
# psycholinguists, literacy researchers, and language scientists.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/language_processing_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    condition = factor(condition),
    item_id = factor(item_id),
    modality = factor(modality),
    comprehension_accuracy = as.integer(comprehension_accuracy),
    lexical_decision_accuracy = as.integer(lexical_decision_accuracy),
    production_accuracy = as.integer(production_accuracy),
    log_reading_time = log(reading_time_ms),
    log_lexical_decision_rt = log(lexical_decision_rt_ms),
    log_production_latency = log(production_latency_ms)
  )

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    mean_word_frequency = mean(word_frequency, na.rm = TRUE),
    mean_lexical_ambiguity = mean(lexical_ambiguity, na.rm = TRUE),
    mean_syntactic_complexity = mean(syntactic_complexity, na.rm = TRUE),
    mean_semantic_predictability = mean(semantic_predictability, na.rm = TRUE),
    mean_context_support = mean(context_support, na.rm = TRUE),
    mean_working_memory_load = mean(working_memory_load, na.rm = TRUE),
    mean_pragmatic_demand = mean(pragmatic_inference_demand, na.rm = TRUE),
    mean_discourse_coherence = mean(discourse_coherence, na.rm = TRUE),
    comprehension_accuracy_rate = mean(comprehension_accuracy, na.rm = TRUE),
    lexical_decision_accuracy_rate = mean(lexical_decision_accuracy, na.rm = TRUE),
    production_accuracy_rate = mean(production_accuracy, na.rm = TRUE),
    mean_reading_time_ms = mean(reading_time_ms, na.rm = TRUE),
    mean_lexical_decision_rt_ms = mean(lexical_decision_rt_ms, na.rm = TRUE),
    mean_production_latency_ms = mean(production_latency_ms, na.rm = TRUE),
    mean_confidence = mean(confidence, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

comprehension_model <- glmer(
  comprehension_accuracy ~
    condition +
    modality +
    word_frequency +
    lexical_ambiguity +
    syntactic_complexity +
    semantic_predictability +
    context_support +
    working_memory_load +
    pragmatic_inference_demand +
    discourse_coherence +
    (1 | participant) +
    (1 | item_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

lexical_model <- glmer(
  lexical_decision_accuracy ~
    condition +
    word_frequency +
    lexical_ambiguity +
    semantic_predictability +
    working_memory_load +
    (1 | participant) +
    (1 | item_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

production_model <- glmer(
  production_accuracy ~
    condition +
    modality +
    word_frequency +
    lexical_ambiguity +
    syntactic_complexity +
    context_support +
    working_memory_load +
    pragmatic_inference_demand +
    discourse_coherence +
    (1 | participant) +
    (1 | item_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

reading_model <- lmer(
  log_reading_time ~
    condition +
    modality +
    word_frequency +
    lexical_ambiguity +
    syntactic_complexity +
    semantic_predictability +
    context_support +
    working_memory_load +
    pragmatic_inference_demand +
    comprehension_accuracy +
    (1 | participant) +
    (1 | item_id),
  data = dat,
  REML = FALSE
)

lexrt_model <- lmer(
  log_lexical_decision_rt ~
    condition +
    word_frequency +
    lexical_ambiguity +
    semantic_predictability +
    working_memory_load +
    lexical_decision_accuracy +
    (1 | participant) +
    (1 | item_id),
  data = dat,
  REML = FALSE
)

production_latency_model <- lmer(
  log_production_latency ~
    condition +
    modality +
    word_frequency +
    lexical_ambiguity +
    syntactic_complexity +
    context_support +
    working_memory_load +
    pragmatic_inference_demand +
    production_accuracy +
    (1 | participant) +
    (1 | item_id),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    comprehension_model = summary(comprehension_model),
    lexical_decision_model = summary(lexical_model),
    production_accuracy_model = summary(production_model),
    reading_time_model = summary(reading_model),
    lexical_decision_rt_model = summary(lexrt_model),
    production_latency_model = summary(production_latency_model),
    condition_comprehension = emmeans(comprehension_model, ~ condition, type = "response"),
    condition_reading = emmeans(reading_model, ~ condition),
    condition_lexical_rt = emmeans(lexrt_model, ~ condition)
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(comprehension_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_comprehension_model_coefficients.csv"))
write_csv(tidy(lexical_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_lexical_decision_coefficients.csv"))
write_csv(tidy(production_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_production_accuracy_coefficients.csv"))
write_csv(tidy(reading_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_reading_time_coefficients.csv"))
write_csv(tidy(lexrt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_lexical_rt_coefficients.csv"))
write_csv(tidy(production_latency_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_production_latency_coefficients.csv"))

p <- ggplot(dat, aes(x = syntactic_complexity, y = reading_time_ms, color = condition)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Syntactic complexity and reading time",
    x = "Syntactic complexity",
    y = "Reading time (ms)"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_syntactic_complexity_reading_time.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
