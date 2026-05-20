#!/usr/bin/env Rscript

# Sensory memory in cognitive psychology.
# Hierarchical workflow for cue delay, modality, trace decay, partial report,
# masking, attentional priority, correct report, working-memory transfer, and RT.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = TRUE)

input_path <- ifelse(length(args) >= 1, args[[1]], "data/sensory_memory_trials.csv")
output_dir <- ifelse(length(args) >= 2, args[[2]], "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read_csv(input_path, show_col_types = FALSE) %>%
  mutate(
    participant = factor(participant),
    modality = factor(modality),
    condition = factor(condition),
    stimulus_id = factor(stimulus_id),
    correct = as.integer(correct),
    mask_present = as.integer(mask_present),
    wm_transfer = as.integer(wm_transfer),
    log_rt = log(rt_ms)
  )

delay_summary <- dat %>%
  group_by(modality, cue_delay_ms) %>%
  summarise(
    n_trials = n(),
    accuracy = mean(correct, na.rm = TRUE),
    mean_report = mean(report_score, na.rm = TRUE),
    mean_trace = mean(trace_strength, na.rm = TRUE),
    mean_selection = mean(selection_probability, na.rm = TRUE),
    wm_transfer_rate = mean(wm_transfer, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(delay_summary, file.path(output_dir, "r_summary_by_modality_delay.csv"))

condition_summary <- dat %>%
  group_by(condition) %>%
  summarise(
    n_trials = n(),
    participants = n_distinct(participant),
    accuracy = mean(correct, na.rm = TRUE),
    mean_report = mean(report_score, na.rm = TRUE),
    mean_trace = mean(trace_strength, na.rm = TRUE),
    wm_transfer_rate = mean(wm_transfer, na.rm = TRUE),
    mean_rt_ms = mean(rt_ms, na.rm = TRUE),
    mean_confidence = mean(confidence, na.rm = TRUE),
    mean_perceptual_continuity = mean(perceptual_continuity, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(condition_summary, file.path(output_dir, "r_summary_by_condition.csv"))

correct_model <- glmer(
  correct ~
    cue_delay_ms * modality +
    condition +
    stimulus_duration_ms +
    array_size +
    cue_validity +
    mask_present +
    trace_strength +
    salience +
    attentional_priority +
    (1 | participant) +
    (1 | stimulus_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

report_model <- lmer(
  report_score ~
    cue_delay_ms * modality +
    condition +
    array_size +
    cue_validity +
    mask_present +
    trace_strength +
    salience +
    attentional_priority +
    (1 | participant) +
    (1 | stimulus_id),
  data = dat,
  REML = FALSE
)

transfer_model <- glmer(
  wm_transfer ~
    cue_delay_ms +
    modality +
    condition +
    trace_strength +
    correct +
    cue_validity +
    attentional_priority +
    mask_present +
    (1 | participant) +
    (1 | stimulus_id),
  data = dat,
  family = binomial(),
  control = glmerControl(optimizer = "bobyqa")
)

rt_model <- lmer(
  log_rt ~
    cue_delay_ms * modality +
    condition +
    array_size +
    correct +
    mask_present +
    attentional_priority +
    confidence +
    (1 | participant) +
    (1 | stimulus_id),
  data = dat,
  REML = FALSE
)

continuity_model <- lmer(
  perceptual_continuity ~
    modality +
    condition +
    trace_strength +
    wm_transfer +
    mask_present +
    cue_delay_ms +
    confidence +
    (1 | participant) +
    (1 | stimulus_id),
  data = dat,
  REML = FALSE
)

decay_estimates <- delay_summary %>%
  filter(accuracy > 0) %>%
  group_by(modality) %>%
  group_modify(~{
    out <- tryCatch(
      {
        fit <- nls(
          accuracy ~ a * exp(-lambda * cue_delay_ms),
          data = .x,
          start = list(a = 0.9, lambda = 0.001),
          control = nls.control(maxiter = 200)
        )
        tibble(a = coef(fit)[["a"]], lambda = coef(fit)[["lambda"]])
      },
      error = function(e) tibble(a = NA_real_, lambda = NA_real_)
    )
    out
  }) %>%
  ungroup()

write_csv(decay_estimates, file.path(output_dir, "r_decay_parameter_estimates.csv"))

capture.output(
  list(
    correct_model = summary(correct_model),
    report_model = summary(report_model),
    transfer_model = summary(transfer_model),
    response_time_model = summary(rt_model),
    continuity_model = summary(continuity_model),
    modality_accuracy = emmeans(correct_model, ~ modality, type = "response"),
    condition_accuracy = emmeans(correct_model, ~ condition, type = "response")
  ),
  file = file.path(output_dir, "r_model_summaries.txt")
)

write_csv(tidy(correct_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_correct_coefficients.csv"))
write_csv(tidy(report_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_report_score_coefficients.csv"))
write_csv(tidy(transfer_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_wm_transfer_coefficients.csv"))
write_csv(tidy(rt_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_response_time_coefficients.csv"))
write_csv(tidy(continuity_model, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_continuity_coefficients.csv"))

p <- ggplot(delay_summary, aes(x = cue_delay_ms, y = accuracy, color = modality)) +
  geom_point() +
  geom_line() +
  labs(
    title = "Sensory trace accuracy across cue delay",
    x = "Cue delay in milliseconds",
    y = "Correct report rate"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(output_dir, "r_accuracy_by_cue_delay.png"),
  plot = p,
  width = 9,
  height = 6,
  dpi = 300
)

message("R analysis complete. Outputs written to: ", output_dir)
