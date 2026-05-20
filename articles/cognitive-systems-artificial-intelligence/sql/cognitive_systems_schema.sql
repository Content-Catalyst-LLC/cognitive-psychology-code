-- Cognitive systems in artificial intelligence.
-- Research schema and analytical views.

DROP TABLE IF EXISTS cognitive_systems_trials;

CREATE TABLE cognitive_systems_trials (
    agent_id TEXT NOT NULL,
    architecture TEXT NOT NULL,
    task_condition TEXT NOT NULL,
    trial INTEGER NOT NULL,
    input_noise REAL NOT NULL CHECK (input_noise >= 0 AND input_noise <= 10),
    representation_quality REAL NOT NULL CHECK (representation_quality >= 0 AND representation_quality <= 10),
    working_memory_load REAL NOT NULL CHECK (working_memory_load >= 0 AND working_memory_load <= 10),
    retrieval_latency_ms REAL NOT NULL CHECK (retrieval_latency_ms >= 1),
    uncertainty_level REAL NOT NULL CHECK (uncertainty_level >= 0 AND uncertainty_level <= 10),
    policy_entropy REAL NOT NULL CHECK (policy_entropy >= 0 AND policy_entropy <= 5),
    prediction_accuracy REAL NOT NULL CHECK (prediction_accuracy >= 0 AND prediction_accuracy <= 1),
    action_success INTEGER NOT NULL CHECK (action_success IN (0, 1)),
    explanation_score REAL NOT NULL CHECK (explanation_score >= 0 AND explanation_score <= 10),
    human_trust REAL NOT NULL CHECK (human_trust >= 0 AND human_trust <= 10),
    override_decision INTEGER NOT NULL CHECK (override_decision IN (0, 1)),
    response_time_ms REAL NOT NULL CHECK (response_time_ms >= 1),
    calibration_error REAL NOT NULL CHECK (calibration_error >= 0 AND calibration_error <= 1),
    cognitive_system_score REAL GENERATED ALWAYS AS (
        prediction_accuracy +
        action_success +
        representation_quality / 10.0 +
        explanation_score / 10.0 -
        policy_entropy / 5.0 -
        calibration_error
    ) VIRTUAL
);

CREATE INDEX idx_cognitive_systems_architecture ON cognitive_systems_trials(architecture);
CREATE INDEX idx_cognitive_systems_condition ON cognitive_systems_trials(task_condition);
CREATE INDEX idx_cognitive_systems_agent ON cognitive_systems_trials(agent_id);

DROP VIEW IF EXISTS architecture_summary;

CREATE VIEW architecture_summary AS
SELECT
    architecture,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT agent_id) AS n_agents,
    AVG(representation_quality) AS mean_representation_quality,
    AVG(retrieval_latency_ms) AS mean_retrieval_latency_ms,
    AVG(uncertainty_level) AS mean_uncertainty,
    AVG(policy_entropy) AS mean_policy_entropy,
    AVG(prediction_accuracy) AS mean_prediction_accuracy,
    AVG(action_success) AS action_success_rate,
    AVG(explanation_score) AS mean_explanation_score,
    AVG(human_trust) AS mean_human_trust,
    AVG(override_decision) AS override_rate,
    AVG(calibration_error) AS mean_calibration_error,
    AVG(cognitive_system_score) AS mean_cognitive_system_score
FROM cognitive_systems_trials
GROUP BY architecture;

DROP VIEW IF EXISTS high_risk_trials;

CREATE VIEW high_risk_trials AS
SELECT
    agent_id,
    architecture,
    task_condition,
    trial,
    uncertainty_level,
    policy_entropy,
    prediction_accuracy,
    explanation_score,
    calibration_error,
    override_decision,
    cognitive_system_score
FROM cognitive_systems_trials
WHERE uncertainty_level >= 7
   OR calibration_error >= 0.20
   OR cognitive_system_score <= 1.0;

DROP VIEW IF EXISTS task_condition_summary;

CREATE VIEW task_condition_summary AS
SELECT
    task_condition,
    COUNT(*) AS n_trials,
    AVG(input_noise) AS mean_input_noise,
    AVG(working_memory_load) AS mean_working_memory_load,
    AVG(uncertainty_level) AS mean_uncertainty,
    AVG(prediction_accuracy) AS mean_prediction_accuracy,
    AVG(action_success) AS action_success_rate,
    AVG(explanation_score) AS mean_explanation_score,
    AVG(override_decision) AS override_rate
FROM cognitive_systems_trials
GROUP BY task_condition;
