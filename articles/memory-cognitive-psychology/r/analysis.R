# Synthetic cognitive psychology analysis.
# Run after the Python script creates data/processed/synthetic_trials.csv.

data_path <- file.path("data", "processed", "synthetic_trials.csv")

if (!file.exists(data_path)) {
  stop("Run: python3 python/cognitive_task_simulation.py")
}

trials <- read.csv(data_path)

summary_table <- aggregate(
  cbind(reaction_time_ms, correct) ~ cognitive_load_level,
  data = trials,
  FUN = mean
)

names(summary_table) <- c("cognitive_load_level", "mean_reaction_time_ms", "mean_accuracy")

dir.create("outputs", showWarnings = FALSE, recursive = TRUE)
write.csv(summary_table, file.path("outputs", "load_summary.csv"), row.names = FALSE)

print(summary_table)
