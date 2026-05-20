#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)
input_path <- ifelse(length(args) >= 1, args[[1]], "data/attention_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    condition = factor(condition),
    domain = factor(domain),
    stimulus_id = factor(stimulus_id),
    cue_validity = factor(cue_validity, levels = c("invalid", "neutral", "valid", "none")),
    task_type = factor(task_type),
    target_present = as.integer(target_present),
    response_yes = as.integer(response_yes),
    correct = as.integer(correct),
    task_switch = as.integer(task_switch),
    block_z = as.numeric(scale(block)),
    log_rt = log(rt)
  ) %>%
  filter(rt >= 150, rt <= 60000)

sdt <- dat %>%
  group_by(participant, condition) %>%
  summarise(
    hits = sum(target_present == 1 & response_yes == 1, na.rm = TRUE),
    misses = sum(target_present == 1 & response_yes == 0, na.rm = TRUE),
    false_alarms = sum(target_present == 0 & response_yes == 1, na.rm = TRUE),
    correct_rejections = sum(target_present == 0 & response_yes == 0, na.rm = TRUE),
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
    yes_rate = mean(response_yes, na.rm = TRUE),
    mean_rt = mean(rt, na.rm = TRUE),
    mean_confidence = mean(confidence, na.rm = TRUE),
    mean_lapse_probability = mean(lapse_probability, na.rm = TRUE),
    mean_vigilance_state = mean(vigilance_state, na.rm = TRUE),
    mean_distractor_load = mean(distractor_load, na.rm = TRUE),
    mean_executive_load = mean(executive_load, na.rm = TRUE),
    mean_divided_attention_cost = mean(divided_attention_cost, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

acc_model <- glmer(
  correct ~
    condition + cue_validity + task_type + block_z + salience + goal_relevance +
    distractor_load + perceptual_load + executive_load + task_switch + conflict +
    vigilance_state + interface_salience + notification_load +
    (1 + block_z | participant) + (1 | stimulus_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

response_model <- glmer(
  response_yes ~
    condition + cue_validity + target_present + salience + goal_relevance +
    distractor_load + perceptual_load + executive_load + conflict + vigilance_state +
    lapse_probability + confidence + interface_salience +
    (1 | participant) + (1 | stimulus_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

rt_dat <- dat %>% filter(correct == 1)

rt_model <- lmer(
  log_rt ~
    condition + cue_validity + task_type + block_z + salience + goal_relevance +
    distractor_load + perceptual_load + executive_load + task_switch + conflict +
    vigilance_state + confidence + interface_salience + notification_load +
    (1 + block_z | participant) + (1 | stimulus_id),
  data = rt_dat,
  REML = FALSE
)

vigilance_model <- glmer(
  correct ~
    block_z * condition + vigilance_state + lapse_probability + distractor_load +
    executive_load + (1 + block_z | participant),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

lapse_model <- lmer(
  lapse_probability ~
    condition + block_z + vigilance_state + distractor_load + executive_load +
    notification_load + divided_attention_cost + (1 + block_z | participant),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    accuracy_model = summary(acc_model),
    response_yes_model = summary(response_model),
    response_time_model = summary(rt_model),
    vigilance_model = summary(vigilance_model),
    lapse_model = summary(lapse_model),
    accuracy_by_condition = emmeans(acc_model, ~ condition, type = "response"),
    cue_validity_rt = emmeans(rt_model, ~ cue_validity)
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(acc_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_accuracy_coefficients.csv"))
write_csv(tidy(response_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_yes_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_coefficients.csv"))
write_csv(tidy(vigilance_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_vigilance_coefficients.csv"))
write_csv(tidy(lapse_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_lapse_coefficients.csv"))

cue_effects <- rt_dat %>%
  filter(cue_validity %in% c("valid", "neutral", "invalid")) %>%
  group_by(participant, condition, cue_validity) %>%
  summarise(mean_rt = mean(rt, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = cue_validity, values_from = mean_rt) %>%
  mutate(
    orienting_benefit = neutral - valid,
    reorienting_cost = invalid - neutral,
    total_validity_effect = invalid - valid
  )

write_csv(cue_effects, file.path(output_dir, "r_cueing_effects.csv"))

vig_plot_data <- dat %>%
  group_by(condition, block) %>%
  summarise(correct_rate = mean(correct), lapse = mean(lapse_probability), .groups = "drop")

p <- ggplot(vig_plot_data, aes(x = block, y = correct_rate, color = condition)) +
  geom_point(alpha = 0.75) +
  geom_line(alpha = 0.75) +
  labs(title = "Sustained attention across time-on-task", x = "Block", y = "Correct rate") +
  theme_minimal(base_size = 12)

ggsave(file.path(output_dir, "r_vigilance_by_block.png"), p, width = 9, height = 6, dpi = 300)

message("R analysis complete. Outputs written to: ", output_dir)
