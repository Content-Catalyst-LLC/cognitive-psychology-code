-- Working memory in cognitive psychology.
-- Research schema and analytical views.

DROP TABLE IF EXISTS working_memory_trials;

CREATE TABLE working_memory_trials (
    participant TEXT NOT NULL,
    condition TEXT NOT NULL,
    domain TEXT NOT NULL,
    trial INTEGER NOT NULL CHECK (trial >= 1),
    task_type TEXT NOT NULL,
    modality TEXT NOT NULL,
    load INTEGER NOT NULL CHECK (load >= 1),
    serial_position INTEGER NOT NULL CHECK (serial_position >= 1),
    distractor_level REAL NOT NULL CHECK (distractor_level >= 0 AND distractor_level <= 10),
    interference REAL NOT NULL CHECK (interference >= 0 AND interference <= 10),
    attentional_control REAL NOT NULL CHECK (attentional_control >= 0 AND attentional_control <= 10),
    updating_demand REAL NOT NULL CHECK (updating_demand >= 0 AND updating_demand <= 10),
    storage_demand REAL NOT NULL CHECK (storage_demand >= 0 AND storage_demand <= 10),
    processing_demand REAL NOT NULL CHECK (processing_demand >= 0 AND processing_demand <= 10),
    chunking_support REAL NOT NULL CHECK (chunking_support >= 0 AND chunking_support <= 10),
    rehearsal_opportunity REAL NOT NULL CHECK (rehearsal_opportunity >= 0 AND rehearsal_opportunity <= 10),
    cognitive_load REAL NOT NULL CHECK (cognitive_load >= 0 AND cognitive_load <= 10),
    span_score REAL NOT NULL CHECK (span_score >= 0),
    updating_score REAL NOT NULL CHECK (updating_score >= 0 AND updating_score <= 1),
    capacity_estimate REAL NOT NULL CHECK (capacity_estimate >= 0),
    overload_probability REAL NOT NULL CHECK (overload_probability >= 0 AND overload_probability <= 1),
    dual_task_cost REAL NOT NULL CHECK (dual_task_cost >= 0 AND dual_task_cost <= 1),
    correct INTEGER NOT NULL CHECK (correct IN (0, 1)),
    accuracy REAL NOT NULL CHECK (accuracy >= 0 AND accuracy <= 1),
    response_time_ms REAL NOT NULL CHECK (response_time_ms >= 150),
    confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
    learning_support REAL NOT NULL CHECK (learning_support >= 0 AND learning_support <= 10),
    interface_complexity REAL NOT NULL CHECK (interface_complexity >= 0 AND interface_complexity <= 10),
    overload_index REAL GENERATED ALWAYS AS (
        CASE WHEN load > capacity_estimate THEN load - capacity_estimate ELSE 0 END
    ) VIRTUAL
);

CREATE INDEX idx_wm_participant ON working_memory_trials(participant);
CREATE INDEX idx_wm_condition ON working_memory_trials(condition);
CREATE INDEX idx_wm_task_type ON working_memory_trials(task_type);
CREATE INDEX idx_wm_modality ON working_memory_trials(modality);
CREATE INDEX idx_wm_load ON working_memory_trials(load);

DROP VIEW IF EXISTS condition_summary;

CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(load) AS mean_load,
    AVG(correct) AS correct_rate,
    AVG(accuracy) AS mean_accuracy,
    AVG(response_time_ms) AS mean_response_time_ms,
    AVG(span_score) AS mean_span_score,
    AVG(updating_score) AS mean_updating_score,
    AVG(capacity_estimate) AS mean_capacity_estimate,
    AVG(overload_probability) AS mean_overload_probability,
    AVG(dual_task_cost) AS mean_dual_task_cost,
    AVG(cognitive_load) AS mean_cognitive_load,
    AVG(confidence) AS mean_confidence
FROM working_memory_trials
GROUP BY condition;

DROP VIEW IF EXISTS task_summary;

CREATE VIEW task_summary AS
SELECT
    task_type,
    COUNT(*) AS n_trials,
    AVG(correct) AS correct_rate,
    AVG(accuracy) AS mean_accuracy,
    AVG(response_time_ms) AS mean_response_time_ms,
    AVG(span_score) AS mean_span_score,
    AVG(updating_score) AS mean_updating_score,
    AVG(capacity_estimate) AS mean_capacity_estimate,
    AVG(cognitive_load) AS mean_cognitive_load
FROM working_memory_trials
GROUP BY task_type;

DROP VIEW IF EXISTS overload_cases;

CREATE VIEW overload_cases AS
SELECT
    participant,
    condition,
    domain,
    task_type,
    modality,
    load,
    capacity_estimate,
    overload_index,
    overload_probability,
    cognitive_load,
    interference,
    attentional_control,
    correct,
    accuracy,
    response_time_ms,
    confidence
FROM working_memory_trials
WHERE overload_probability >= 0.70;

DROP VIEW IF EXISTS support_benefit_cases;

CREATE VIEW support_benefit_cases AS
SELECT
    participant,
    condition,
    domain,
    task_type,
    load,
    chunking_support,
    learning_support,
    interface_complexity,
    cognitive_load,
    capacity_estimate,
    accuracy,
    response_time_ms
FROM working_memory_trials
WHERE condition IN ('chunking', 'instructional_support', 'ai_supported')
ORDER BY accuracy DESC;

DROP VIEW IF EXISTS high_interference_cases;

CREATE VIEW high_interference_cases AS
SELECT
    participant,
    condition,
    task_type,
    modality,
    load,
    distractor_level,
    interference,
    attentional_control,
    dual_task_cost,
    accuracy,
    response_time_ms
FROM working_memory_trials
WHERE interference >= 7;
