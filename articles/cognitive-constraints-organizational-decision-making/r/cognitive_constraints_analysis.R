#!/usr/bin/env Rscript

# Cognitive constraints in organizational decision making.
# Hierarchical and descriptive workflow for cognitive psychologists
# and organizational decision researchers.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/organizational_decision_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    unit = factor(unit),
    condition = factor(condition),
    chose_satisficing = as.integer(chose_satisficing),
    dissent_present = as.integer(dissent_present),
    log_response_time = log(response_time_ms),
    cognitive_burden = ifelse(
      "cognitive_burden" %in% names(.),
      cognitive_burden,
      info_load + uncertainty_level + coordination_load +
        institutional_pressure + 0.5 * feedback_delay +
        0.25 * automation_reliance - 0.55 * psychological_safety -
        0.9 * dissent_present
    )
  )

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    mean_info_load = mean(info_load, na.rm = TRUE),
    mean_attention = mean(attention_score, na.rm = TRUE),
    mean_uncertainty = mean(uncertainty_level, na.rm = TRUE),
    mean_coordination = mean(coordination_load, na.rm = TRUE),
    mean_pressure = mean(institutional_pressure, na.rm = TRUE),
    mean_feedback_delay = mean(feedback_delay, na.rm = TRUE),
    mean_safety = mean(psychological_safety, na.rm = TRUE),
    dissent_rate = mean(dissent_present, na.rm = TRUE),
    mean_automation = mean(automation_reliance, na.rm = TRUE),
    mean_cognitive_burden = mean(cognitive_burden, na.rm = TRUE),
    mean_quality = mean(decision_quality, na.rm = TRUE),
    satisficing_rate = mean(chose_satisficing, na.rm = TRUE),
    mean_response_time_ms = mean(response_time_ms, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

quality_model <- lmer(
  decision_quality ~
    info_load +
    attention_score +
    uncertainty_level +
    coordination_load +
    institutional_pressure +
    feedback_delay +
    psychological_safety +
    dissent_present +
    automation_reliance +
    condition +
    (1 | participant),
  data = dat,
  REML = FALSE
)

satisficing_model <- glmer(
  chose_satisficing ~
    info_load +
    attention_score +
    uncertainty_level +
    coordination_load +
    institutional_pressure +
    feedback_delay +
    psychological_safety +
    dissent_present +
    automation_reliance +
    condition +
    (1 | participant),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

rt_model <- lmer(
  log_response_time ~
    info_load +
    attention_score +
    uncertainty_level +
    coordination_load +
    institutional_pressure +
    feedback_delay +
    psychological_safety +
    dissent_present +
    automation_reliance +
    condition +
    (1 | participant),
  data = dat,
  REML = FALSE
)

burden_model <- lmer(
  decision_quality ~ cognitive_burden + condition + (1 | participant),
  data = dat,
  REML = FALSE
)

capture.output(
  list(
    quality_model = summary(quality_model),
    satisficing_model = summary(satisficing_model),
    response_time_model = summary(rt_model),
    burden_model = summary(burden_model),
    condition_effects_quality = emmeans(quality_model, ~ condition),
    condition_effects_satisficing = emmeans(satisficing_model, ~ condition, type = "response")
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

quality_tidy <- tidy(quality_model, effects = "fixed", conf.int = TRUE)
satisficing_tidy <- tidy(satisficing_model, effects = "fixed", conf.int = TRUE)
rt_tidy <- tidy(rt_model, effects = "fixed", conf.int = TRUE)
burden_tidy <- tidy(burden_model, effects = "fixed", conf.int = TRUE)

write_csv(quality_tidy, file.path(output_dir, "r_quality_model_coefficients.csv"))
write_csv(satisficing_tidy, file.path(output_dir, "r_satisficing_model_coefficients.csv"))
write_csv(rt_tidy, file.path(output_dir, "r_response_time_model_coefficients.csv"))
write_csv(burden_tidy, file.path(output_dir, "r_burden_model_coefficients.csv"))

p <- ggplot(dat, aes(x = cognitive_burden, y = decision_quality)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "lm", se = TRUE) +
  facet_wrap(~ condition) +
  labs(
    title = "Cognitive burden and organizational decision quality",
    x = "Cognitive burden index",
    y = "Decision quality"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_cognitive_burden_quality.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
