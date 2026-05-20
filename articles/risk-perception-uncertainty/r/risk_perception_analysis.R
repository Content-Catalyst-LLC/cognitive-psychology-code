#!/usr/bin/env Rscript

# Risk perception and uncertainty.
# Hierarchical workflow for subjective probability, affect, dread, framing,
# perceived risk, safe choice, protective action, and response time.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/risk_perception_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    condition = factor(condition),
    domain = factor(domain),
    scenario_id = factor(scenario_id),
    choose_safe = as.integer(choose_safe),
    protective_action = as.integer(protective_action),
    probability_distortion = subjective_probability - objective_probability,
    risk_benefit_gap = perceived_risk - perceived_benefit,
    log_rt = log(rt_ms)
  )

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    mean_objective_probability = mean(objective_probability, na.rm = TRUE),
    mean_subjective_probability = mean(subjective_probability, na.rm = TRUE),
    mean_probability_distortion = mean(probability_distortion, na.rm = TRUE),
    mean_consequence = mean(consequence_rating, na.rm = TRUE),
    mean_affect = mean(affect_rating, na.rm = TRUE),
    mean_dread = mean(dread_rating, na.rm = TRUE),
    mean_controllability = mean(controllability_rating, na.rm = TRUE),
    mean_trust = mean(trust_rating, na.rm = TRUE),
    mean_ambiguity = mean(ambiguity_rating, na.rm = TRUE),
    mean_clarity = mean(communication_clarity, na.rm = TRUE),
    mean_benefit = mean(perceived_benefit, na.rm = TRUE),
    mean_perceived_risk = mean(perceived_risk, na.rm = TRUE),
    safe_choice_rate = mean(choose_safe, na.rm = TRUE),
    protective_action_rate = mean(protective_action, na.rm = TRUE),
    mean_rt_ms = mean(rt_ms, na.rm = TRUE),
    mean_confidence = mean(confidence, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

risk_model <- lmer(
  perceived_risk ~
    condition +
    domain +
    objective_probability +
    subjective_probability +
    consequence_rating +
    affect_rating +
    dread_rating +
    familiarity_rating +
    controllability_rating +
    trust_rating +
    ambiguity_rating +
    communication_clarity +
    perceived_benefit +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

distortion_model <- lmer(
  probability_distortion ~
    condition +
    domain +
    objective_probability +
    affect_rating +
    dread_rating +
    ambiguity_rating +
    communication_clarity +
    trust_rating +
    confidence +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

safe_model <- glmer(
  choose_safe ~
    condition +
    domain +
    perceived_risk +
    consequence_rating +
    affect_rating +
    dread_rating +
    controllability_rating +
    trust_rating +
    ambiguity_rating +
    perceived_benefit +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

action_model <- glmer(
  protective_action ~
    condition +
    domain +
    perceived_risk +
    trust_rating +
    communication_clarity +
    controllability_rating +
    ambiguity_rating +
    confidence +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

clarity_model <- lmer(
  communication_clarity ~
    condition +
    domain +
    trust_rating +
    ambiguity_rating +
    objective_probability +
    consequence_rating +
    affect_rating +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

rt_model <- lmer(
  log_rt ~
    condition +
    domain +
    perceived_risk +
    ambiguity_rating +
    communication_clarity +
    confidence +
    choose_safe +
    protective_action +
    (1 | participant) +
    (1 | scenario_id),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    risk_model = summary(risk_model),
    distortion_model = summary(distortion_model),
    safe_choice_model = summary(safe_model),
    protective_action_model = summary(action_model),
    communication_clarity_model = summary(clarity_model),
    response_time_model = summary(rt_model),
    condition_risk = emmeans(risk_model, ~ condition),
    frame_safe_choice = emmeans(safe_model, ~ condition, type = "response"),
    frame_protective_action = emmeans(action_model, ~ condition, type = "response")
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(risk_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_perceived_risk_coefficients.csv"))
write_csv(tidy(distortion_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_probability_distortion_coefficients.csv"))
write_csv(tidy(safe_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_safe_choice_coefficients.csv"))
write_csv(tidy(action_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_protective_action_coefficients.csv"))
write_csv(tidy(clarity_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_clarity_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_coefficients.csv"))

p <- ggplot(dat, aes(x = subjective_probability, y = perceived_risk, color = condition)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Subjective probability and perceived risk",
    x = "Subjective probability",
    y = "Perceived risk"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_subjective_probability_perceived_risk.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
