-- Cognitive load and information processing.
-- Research schema and analytical views.

DROP TABLE IF EXISTS cognitive_load_trials;

CREATE TABLE cognitive_load_trials (
    participant TEXT NOT NULL,
    condition TEXT NOT NULL,
    domain TEXT NOT NULL,
    trial INTEGER NOT NULL CHECK (trial >= 1),
    task_id TEXT NOT NULL,
    expertise_level TEXT NOT NULL,
    intrinsic_load REAL NOT NULL CHECK (intrinsic_load >= 0 AND intrinsic_load <= 10),
    extraneous_load REAL NOT NULL CHECK (extraneous_load >= 0 AND extraneous_load <= 10),
    germane_load REAL NOT NULL CHECK (germane_load >= 0 AND germane_load <= 10),
    element_interactivity REAL NOT NULL CHECK (element_interactivity >= 0 AND element_interactivity <= 10),
    prior_knowledge REAL NOT NULL CHECK (prior_knowledge >= 0 AND prior_knowledge <= 10),
    working_memory_capacity REAL NOT NULL CHECK (working_memory_capacity >= 0 AND working_memory_capacity <= 10),
    design_quality REAL NOT NULL CHECK (design_quality >= 0 AND design_quality <= 10),
    split_attention REAL NOT NULL CHECK (split_attention >= 0 AND split_attention <= 10),
    redundancy REAL NOT NULL CHECK (redundancy >= 0 AND redundancy <= 10),
    subjective_effort REAL NOT NULL CHECK (subjective_effort >= 0 AND subjective_effort <= 10),
    mental_demand REAL NOT NULL CHECK (mental_demand >= 0 AND mental_demand <= 10),
    temporal_demand REAL NOT NULL CHECK (temporal_demand >= 0 AND temporal_demand <= 10),
    frustration REAL NOT NULL CHECK (frustration >= 0 AND frustration <= 10),
    performance_accuracy REAL NOT NULL CHECK (performance_accuracy >= 0 AND performance_accuracy <= 1),
    correct INTEGER NOT NULL CHECK (correct IN (0, 1)),
    rt_ms REAL NOT NULL CHECK (rt_ms >= 150),
    error_rate REAL NOT NULL CHECK (error_rate >= 0 AND error_rate <= 1),
    transfer_score REAL NOT NULL CHECK (transfer_score >= 0 AND transfer_score <= 100),
    learning_gain REAL NOT NULL CHECK (learning_gain >= 0 AND learning_gain <= 100),
    mental_efficiency REAL NOT NULL,
    confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 10),
    total_load REAL GENERATED ALWAYS AS (intrinsic_load + extraneous_load + germane_load) VIRTUAL,
    effective_load REAL GENERATED ALWAYS AS (intrinsic_load + extraneous_load - 0.25 * prior_knowledge) VIRTUAL,
    overload_margin REAL GENERATED ALWAYS AS (
        working_memory_capacity + 0.45 * prior_knowledge - (intrinsic_load + extraneous_load + 0.55 * germane_load)
    ) VIRTUAL
);

CREATE INDEX idx_cl_participant ON cognitive_load_trials(participant);
CREATE INDEX idx_cl_condition ON cognitive_load_trials(condition);
CREATE INDEX idx_cl_domain ON cognitive_load_trials(domain);
CREATE INDEX idx_cl_expertise ON cognitive_load_trials(expertise_level);
CREATE INDEX idx_cl_task ON cognitive_load_trials(task_id);

DROP VIEW IF EXISTS condition_summary;

CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(intrinsic_load) AS mean_intrinsic,
    AVG(extraneous_load) AS mean_extraneous,
    AVG(germane_load) AS mean_germane,
    AVG(total_load) AS mean_total_load,
    AVG(subjective_effort) AS mean_effort,
    AVG(mental_demand) AS mean_mental_demand,
    AVG(frustration) AS mean_frustration,
    AVG(performance_accuracy) AS mean_accuracy,
    AVG(correct) AS correct_rate,
    AVG(rt_ms) AS mean_rt_ms,
    AVG(transfer_score) AS mean_transfer,
    AVG(learning_gain) AS mean_learning_gain,
    AVG(mental_efficiency) AS mean_efficiency,
    AVG(confidence) AS mean_confidence
FROM cognitive_load_trials
GROUP BY condition;

DROP VIEW IF EXISTS expertise_condition_summary;

CREATE VIEW expertise_condition_summary AS
SELECT
    expertise_level,
    condition,
    COUNT(*) AS n_trials,
    AVG(prior_knowledge) AS mean_prior_knowledge,
    AVG(effective_load) AS mean_effective_load,
    AVG(correct) AS correct_rate,
    AVG(subjective_effort) AS mean_effort,
    AVG(transfer_score) AS mean_transfer,
    AVG(mental_efficiency) AS mean_efficiency
FROM cognitive_load_trials
GROUP BY expertise_level, condition;

DROP VIEW IF EXISTS overload_cases;

CREATE VIEW overload_cases AS
SELECT
    participant,
    condition,
    domain,
    task_id,
    expertise_level,
    intrinsic_load,
    extraneous_load,
    germane_load,
    working_memory_capacity,
    prior_knowledge,
    overload_margin,
    subjective_effort,
    performance_accuracy,
    correct,
    transfer_score
FROM cognitive_load_trials
WHERE overload_margin < 0;

DROP VIEW IF EXISTS high_extraneous_low_performance_cases;

CREATE VIEW high_extraneous_low_performance_cases AS
SELECT
    participant,
    condition,
    domain,
    task_id,
    expertise_level,
    extraneous_load,
    split_attention,
    redundancy,
    design_quality,
    subjective_effort,
    performance_accuracy,
    correct,
    mental_efficiency
FROM cognitive_load_trials
WHERE extraneous_load >= 6.5
  AND performance_accuracy < 0.65;
