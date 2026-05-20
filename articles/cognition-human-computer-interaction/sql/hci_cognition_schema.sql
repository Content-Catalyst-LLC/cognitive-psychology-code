-- Cognition in human-computer interaction.
-- Research schema and analytical views.

DROP TABLE IF EXISTS hci_trials;

CREATE TABLE hci_trials (
    participant TEXT NOT NULL,
    interface_condition TEXT NOT NULL,
    task_id TEXT NOT NULL,
    trial INTEGER NOT NULL,
    task_difficulty REAL NOT NULL CHECK (task_difficulty >= 0 AND task_difficulty <= 10),
    perceptual_load REAL NOT NULL CHECK (perceptual_load >= 0 AND perceptual_load <= 10),
    attentional_demand REAL NOT NULL CHECK (attentional_demand >= 0 AND attentional_demand <= 10),
    working_memory_load REAL NOT NULL CHECK (working_memory_load >= 0 AND working_memory_load <= 10),
    cognitive_load REAL NOT NULL CHECK (cognitive_load >= 0 AND cognitive_load <= 10),
    alignment_score REAL NOT NULL CHECK (alignment_score >= 0 AND alignment_score <= 10),
    trust_score REAL NOT NULL CHECK (trust_score >= 0 AND trust_score <= 10),
    automation_reliance REAL NOT NULL CHECK (automation_reliance >= 0 AND automation_reliance <= 10),
    accessibility_friction REAL NOT NULL CHECK (accessibility_friction >= 0 AND accessibility_friction <= 10),
    success INTEGER NOT NULL CHECK (success IN (0, 1)),
    response_time_ms REAL NOT NULL CHECK (response_time_ms >= 150),
    error_count INTEGER NOT NULL CHECK (error_count >= 0),
    warning_detected INTEGER NOT NULL CHECK (warning_detected IN (0, 1)),
    interaction_cost REAL GENERATED ALWAYS AS (
        perceptual_load +
        attentional_demand +
        working_memory_load +
        cognitive_load +
        0.5 * accessibility_friction -
        0.6 * alignment_score
    ) VIRTUAL
);

CREATE INDEX idx_hci_condition ON hci_trials(interface_condition);
CREATE INDEX idx_hci_participant ON hci_trials(participant);
CREATE INDEX idx_hci_task ON hci_trials(task_id);

DROP VIEW IF EXISTS interface_condition_summary;

CREATE VIEW interface_condition_summary AS
SELECT
    interface_condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(task_difficulty) AS mean_task_difficulty,
    AVG(perceptual_load) AS mean_perceptual_load,
    AVG(attentional_demand) AS mean_attentional_demand,
    AVG(working_memory_load) AS mean_working_memory_load,
    AVG(cognitive_load) AS mean_cognitive_load,
    AVG(alignment_score) AS mean_alignment,
    AVG(trust_score) AS mean_trust,
    AVG(accessibility_friction) AS mean_accessibility_friction,
    AVG(interaction_cost) AS mean_interaction_cost,
    AVG(success) AS success_rate,
    AVG(warning_detected) AS warning_detection_rate,
    AVG(error_count) AS mean_errors,
    AVG(response_time_ms) AS mean_response_time_ms
FROM hci_trials
GROUP BY interface_condition;

DROP VIEW IF EXISTS high_friction_trials;

CREATE VIEW high_friction_trials AS
SELECT
    participant,
    interface_condition,
    task_id,
    trial,
    interaction_cost,
    cognitive_load,
    accessibility_friction,
    alignment_score,
    success,
    error_count,
    response_time_ms
FROM hci_trials
WHERE interaction_cost >= 18
   OR cognitive_load >= 8
   OR accessibility_friction >= 6
   OR error_count >= 4;

DROP VIEW IF EXISTS task_summary;

CREATE VIEW task_summary AS
SELECT
    task_id,
    COUNT(*) AS n_trials,
    AVG(task_difficulty) AS mean_task_difficulty,
    AVG(cognitive_load) AS mean_cognitive_load,
    AVG(success) AS success_rate,
    AVG(error_count) AS mean_errors,
    AVG(response_time_ms) AS mean_response_time_ms
FROM hci_trials
GROUP BY task_id;
