#!/usr/bin/env Rscript

# Cognitive psychology and behavioral economics.
# Hierarchical and descriptive workflow for cognitive psychologists,
# behavioral economists, policy researchers, and decision scientists.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/behavioral_economics_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    condition = factor(condition),
    choice_domain = factor(choice_domain),
    gain_loss_frame = factor(gain_loss_frame),
    default_present = as.integer(default_present),
    risky_choice = as.integer(risky_choice),
    default_accepted = as.integer(default_accepted),
    log_decision_time = log(decision_time_ms)
  )

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    mean_cognitive_load = mean(cognitive_load, na.rm = TRUE),
    mean_attention = mean(attention_score, na.rm = TRUE),
    risky_choice_rate = mean(risky_choice, na.rm = TRUE),
    default_acceptance_rate = mean(default_accepted, na.rm = TRUE),
    mean_wtp = mean(willingness_to_pay, na.rm = TRUE),
    mean_decision_time_ms = mean(decision_time_ms, na.rm = TRUE),
    mean_social_norm = mean(social_norm_strength, na.rm = TRUE),
    mean_lambda = mean(loss_aversion_lambda, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

risky_model <- glmer(
  risky_choice ~
    condition +
    gain_loss_frame +
    probability +
    outcome_amount +
    cognitive_load +
    attention_score +
    social_norm_strength +
    loss_aversion_lambda +
    delay_days +
    (1 | participant),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

default_model <- glmer(
  default_accepted ~
    condition +
    default_present +
    cognitive_load +
    attention_score +
    social_norm_strength +
    gain_loss_frame +
    (1 | participant),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

wtp_model <- lmer(
  willingness_to_pay ~
    condition +
    gain_loss_frame +
    outcome_amount +
    probability +
    delay_days +
    cognitive_load +
    attention_score +
    social_norm_strength +
    risky_choice +
    (1 | participant),
  data = dat,
  REML = FALSE
)

rt_model <- lmer(
  log_decision_time ~
    condition +
    gain_loss_frame +
    cognitive_load +
    attention_score +
    delay_days +
    probability +
    outcome_amount +
    (1 | participant),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    risky_choice_model = summary(risky_model),
    default_acceptance_model = summary(default_model),
    willingness_to_pay_model = summary(wtp_model),
    decision_time_model = summary(rt_model),
    condition_risk = emmeans(risky_model, ~ condition, type = "response"),
    condition_default = emmeans(default_model, ~ condition, type = "response"),
    condition_wtp = emmeans(wtp_model, ~ condition)
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(risky_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_risky_choice_coefficients.csv"))
write_csv(tidy(default_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_default_acceptance_coefficients.csv"))
write_csv(tidy(wtp_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_wtp_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_decision_time_coefficients.csv"))

p <- ggplot(dat, aes(x = cognitive_load, y = as.numeric(risky_choice), color = gain_loss_frame)) +
  geom_jitter(height = 0.04, alpha = 0.25) +
  geom_smooth(method = "glm", method.args = list(family = "binomial"), se = FALSE) +
  labs(
    title = "Cognitive load and risky choice by frame",
    x = "Cognitive load",
    y = "Risky choice probability"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_cognitive_load_risky_choice.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
