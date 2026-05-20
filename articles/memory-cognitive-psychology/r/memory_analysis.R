#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)
input_path <- ifelse(length(args) >= 1, args[[1]], "data/memory_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    condition = factor(condition),
    domain = factor(domain),
    item_id = factor(item_id),
    memory_system = factor(memory_system),
    study_type = factor(study_type),
    retrieval_practice = as.integer(retrieval_practice),
    misinformation_exposure = as.integer(misinformation_exposure),
    old_item = as.integer(old_item),
    response_old = as.integer(response_old),
    source_correct = as.integer(source_correct),
    correct = as.integer(correct),
    log_rt = log(response_time_ms)
  )

sdt <- dat %>%
  group_by(participant, condition) %>%
  summarise(
    hits = sum(old_item == 1 & response_old == 1, na.rm = TRUE),
    misses = sum(old_item == 1 & response_old == 0, na.rm = TRUE),
    false_alarms = sum(old_item == 0 & response_old == 1, na.rm = TRUE),
    correct_rejections = sum(old_item == 0 & response_old == 0, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    hit_rate = (hits + 0.5) / (hits + misses + 1),
    false_alarm_rate = (false_alarms + 0.5) / (false_alarms + correct_rejections + 1),
    dprime = qnorm(hit_rate) - qnorm(false_alarm_rate),
    criterion = -0.5 * (qnorm(hit_rate) + qnorm(false_alarm_rate))
  )

write_csv(sdt, file.path(output_dir, "r_signal_detection_by_participant_condition.csv"))

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    correct_rate = mean(correct, na.rm = TRUE),
    mean_recall_accuracy = mean(recall_accuracy, na.rm = TRUE),
    old_response_rate = mean(response_old, na.rm = TRUE),
    source_correct_rate = mean(source_correct, na.rm = TRUE),
    mean_confidence = mean(recognition_confidence, na.rm = TRUE),
    mean_fluency = mean(retrieval_fluency, na.rm = TRUE),
    mean_response_time_ms = mean(response_time_ms, na.rm = TRUE),
    mean_transfer = mean(learning_transfer, na.rm = TRUE),
    mean_retention_strength = mean(retention_strength, na.rm = TRUE),
    mean_forgetting_rate = mean(forgetting_rate, na.rm = TRUE),
    .groups = "drop"
  )
write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

delay_summary <- dat %>%
  group_by(condition, delay) %>%
  summarise(
    n_trials = n(),
    correct_rate = mean(correct, na.rm = TRUE),
    mean_recall_accuracy = mean(recall_accuracy, na.rm = TRUE),
    mean_retention_strength = mean(retention_strength, na.rm = TRUE),
    mean_response_time_ms = mean(response_time_ms, na.rm = TRUE),
    .groups = "drop"
  )
write_csv(delay_summary, file.path(output_dir, "r_summary_by_delay.csv"))

correct_model <- glmer(
  correct ~ condition + domain + memory_system + study_type + encoding_depth +
    retrieval_practice + spacing_interval + delay + retention_strength +
    cue_quality + interference + consolidation_support + source_context +
    misinformation_exposure + (1 + delay | participant) + (1 | item_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

recall_model <- lmer(
  recall_accuracy ~ condition + study_type + encoding_depth + retrieval_practice +
    spacing_interval + delay + retention_strength + cue_quality + interference +
    consolidation_support + misinformation_exposure + (1 + delay | participant) + (1 | item_id),
  data = dat,
  REML = FALSE
)

source_model <- glmer(
  source_correct ~ condition + domain + old_item + response_old + encoding_depth +
    source_context + interference + misinformation_exposure + recognition_confidence +
    (1 | participant) + (1 | item_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

old_response_model <- glmer(
  response_old ~ condition + old_item + retention_strength + cue_quality +
    interference + retrieval_fluency + misinformation_exposure + recognition_confidence +
    (1 | participant) + (1 | item_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

rt_model <- lmer(
  log_rt ~ condition + delay + retrieval_practice + retention_strength +
    cue_quality + interference + retrieval_fluency + correct + recognition_confidence +
    (1 + delay | participant) + (1 | item_id),
  data = dat,
  REML = FALSE
)

transfer_model <- lmer(
  learning_transfer ~ condition + study_type + encoding_depth + retrieval_practice +
    spacing_interval + delay + recall_accuracy + retention_strength + interference +
    (1 | participant) + (1 | item_id),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    correct_memory_model = summary(correct_model),
    recall_accuracy_model = summary(recall_model),
    source_memory_model = summary(source_model),
    old_response_model = summary(old_response_model),
    response_time_model = summary(rt_model),
    learning_transfer_model = summary(transfer_model),
    condition_effects = emmeans(correct_model, ~ condition, type = "response")
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(correct_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_correct_memory_coefficients.csv"))
write_csv(tidy(recall_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_recall_accuracy_coefficients.csv"))
write_csv(tidy(source_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_source_memory_coefficients.csv"))
write_csv(tidy(old_response_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_old_response_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_coefficients.csv"))
write_csv(tidy(transfer_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_transfer_coefficients.csv"))

p <- ggplot(delay_summary, aes(x = delay, y = correct_rate, color = condition)) +
  geom_point(alpha = 0.8) +
  geom_line(alpha = 0.7) +
  labs(title = "Memory retention across delay", x = "Delay", y = "Correct response rate") +
  theme_minimal(base_size = 12)

ggsave(file.path(output_dir, "r_retention_by_delay.png"), p, width = 9, height = 6, dpi = 300)
message("R analysis complete. Outputs written to: ", output_dir)
