#!/usr/bin/env Rscript

# Decision making in cognitive psychology.
# Hierarchical workflow for risky choice, expected value, subjective value,
# gain/loss framing, response time, confidence, decision quality,
# AI agreement, and verification burden.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/decision_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    condition = factor(condition),
    domain = factor(domain),
    scenario_id = factor(scenario_id),
    frame = factor(frame),
    gain_loss = factor(gain_loss),
    choice_option = factor(choice_option),
    choice_risky = as.integer(choice_risky),
    optimal_choice = as.integer(optimal_choice),
    ai_recommendation = as.integer(ai_recommendation),
    ai_agreement = as.integer(ai_agreement),
    log_rt = log(response_time_ms)
  )

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    risky_choice_rate = mean(choice_risky, na.rm = TRUE),
    optimal_choice_rate = mean(optimal_choice, na.rm = TRUE),
    mean_accuracy = mean(accuracy, na.rm = TRUE),
    mean_confidence = mean(confidence, na.rm = TRUE),
    mean_decision_quality = mean(decision_quality, na.rm = TRUE),
    mean_response_time_ms = mean(response_time_ms, na.rm = TRUE),
    mean_cognitive_load = mean(cognitive_load, na.rm = TRUE),
    mean_time_pressure = mean(time_pressure, na.rm = TRUE),
    mean_uncertainty = mean(uncertainty, na.rm = TRUE),
    mean_regret = mean(regret, na.rm = TRUE),
    ai_agreement_rate = mean(ai_agreement, na.rm = TRUE),
    mean_verification_burden = mean(verification_burden, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

frame_summary <- dat %>%
  group_by(frame, gain_loss) %>%
  summarise(
    n_trials = n(),
    risky_choice_rate = mean(choice_risky, na.rm = TRUE),
    optimal_choice_rate = mean(optimal_choice, na.rm = TRUE),
    mean_subjective_value = mean(subjective_value, na.rm = TRUE),
    mean_decision_quality = mean(decision_quality, na.rm = TRUE),
    mean_response_time_ms = mean(response_time_ms, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(frame_summary, file.path(output_dir, "r_summary_by_frame_gain_loss.csv"))

risky_model <- glmer(
  choice_risky ~
    condition +
    frame * gain_loss +
    probability +
    payoff +
    expected_value +
    subjective_value +
    probability_weight +
    loss_aversion_lambda +
    cognitive_load +
    time_pressure +
    uncertainty +
    affective_valence +
    ai_recommendation +
    ai_agreement +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

optimal_model <- glmer(
  optimal_choice ~
    condition +
    domain +
    option_count +
    expected_value +
    subjective_value +
    evidence_strength +
    drift_rate_proxy +
    decision_threshold +
    cognitive_load +
    time_pressure +
    uncertainty +
    confidence +
    ai_recommendation +
    verification_burden +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

quality_model <- lmer(
  decision_quality ~
    condition +
    domain +
    optimal_choice +
    accuracy +
    confidence +
    cognitive_load +
    time_pressure +
    uncertainty +
    regret +
    ai_recommendation +
    ai_agreement +
    verification_burden +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

rt_model <- lmer(
  log_rt ~
    condition +
    frame +
    gain_loss +
    option_count +
    evidence_strength +
    drift_rate_proxy +
    decision_threshold +
    cognitive_load +
    time_pressure +
    uncertainty +
    optimal_choice +
    confidence +
    ai_recommendation +
    verification_burden +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

confidence_model <- lmer(
  confidence ~
    condition +
    domain +
    accuracy +
    optimal_choice +
    drift_rate_proxy +
    decision_threshold +
    uncertainty +
    cognitive_load +
    ai_recommendation +
    ai_agreement +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

ai_dat <- dat %>% filter(ai_recommendation == 1)

if (nrow(ai_dat) > 25) {
  ai_model <- glmer(
    ai_agreement ~
      domain +
      probability +
      payoff +
      subjective_value +
      evidence_strength +
      confidence +
      uncertainty +
      cognitive_load +
      verification_burden +
      (1 | participant) +
      (1 | scenario_id),
    data = ai_dat,
    family = binomial(),
    control = glmerControl(optimizer = "bobyqa")
  )
} else {
  ai_model <- NULL
}

capture.output(
  list(
    risky_choice_model = summary(risky_model),
    optimal_choice_model = summary(optimal_model),
    decision_quality_model = summary(quality_model),
    response_time_model = summary(rt_model),
    confidence_model = summary(confidence_model),
    ai_agreement_model = if (!is.null(ai_model)) summary(ai_model) else "Not enough AI-assisted rows.",
    risky_by_frame = emmeans(risky_model, ~ frame * gain_loss, type = "response"),
    quality_by_condition = emmeans(quality_model, ~ condition),
    rt_by_condition = emmeans(rt_model, ~ condition)
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(risky_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_risky_choice_coefficients.csv"))
write_csv(tidy(optimal_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_optimal_choice_coefficients.csv"))
write_csv(tidy(quality_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_decision_quality_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_coefficients.csv"))
write_csv(tidy(confidence_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_confidence_coefficients.csv"))

if (!is.null(ai_model)) {
  write_csv(tidy(ai_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_ai_agreement_coefficients.csv"))
}

p <- ggplot(dat, aes(x = subjective_value, y = choice_risky, color = gain_loss)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "glm", method.args = list(family = "binomial"), se = FALSE) +
  labs(
    title = "Risky choice by subjective value and gain/loss domain",
    x = "Subjective value",
    y = "Risky choice"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_subjective_value_risky_choice.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
