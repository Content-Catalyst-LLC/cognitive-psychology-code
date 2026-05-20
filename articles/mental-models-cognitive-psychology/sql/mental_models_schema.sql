-- Mental models in cognitive psychology.
-- Research schema and analytical views.

DROP TABLE IF EXISTS mental_models_trials;

CREATE TABLE mental_models_trials (
    participant TEXT NOT NULL,
    condition TEXT NOT NULL,
    domain TEXT NOT NULL,
    trial INTEGER NOT NULL CHECK (trial >= 1),
    scenario_id TEXT NOT NULL,
    model_completeness REAL NOT NULL CHECK (model_completeness >= 0 AND model_completeness <= 10),
    model_coherence REAL NOT NULL CHECK (model_coherence >= 0 AND model_coherence <= 10),
    causal_link_accuracy REAL NOT NULL CHECK (causal_link_accuracy >= 0 AND causal_link_accuracy <= 10),
    feedback_loop_recognition REAL NOT NULL CHECK (feedback_loop_recognition >= 0 AND feedback_loop_recognition <= 10),
    boundary_accuracy REAL NOT NULL CHECK (boundary_accuracy >= 0 AND boundary_accuracy <= 10),
    structural_similarity REAL NOT NULL CHECK (structural_similarity >= 0 AND structural_similarity <= 10),
    prediction_error REAL NOT NULL CHECK (prediction_error >= 0),
    system_understanding_score REAL NOT NULL CHECK (system_understanding_score >= 0 AND system_understanding_score <= 100),
    problem_success INTEGER NOT NULL CHECK (problem_success IN (0, 1)),
    intervention_choice_accuracy INTEGER NOT NULL CHECK (intervention_choice_accuracy IN (0, 1)),
    model_revision_score REAL NOT NULL CHECK (model_revision_score >= 0 AND model_revision_score <= 10),
    transfer_score REAL NOT NULL CHECK (transfer_score >= 0 AND transfer_score <= 100),
    reasoning_time_ms REAL NOT NULL CHECK (reasoning_time_ms >= 150),
    confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 10),
    cognitive_load REAL NOT NULL CHECK (cognitive_load >= 0 AND cognitive_load <= 10),
    explanation_quality REAL NOT NULL CHECK (explanation_quality >= 0 AND explanation_quality <= 10),
    model_quality_index REAL GENERATED ALWAYS AS (
        model_completeness + model_coherence + causal_link_accuracy + feedback_loop_recognition + boundary_accuracy
    ) VIRTUAL
);

CREATE INDEX idx_mm_participant ON mental_models_trials(participant);
CREATE INDEX idx_mm_condition ON mental_models_trials(condition);
CREATE INDEX idx_mm_domain ON mental_models_trials(domain);
CREATE INDEX idx_mm_scenario ON mental_models_trials(scenario_id);

DROP VIEW IF EXISTS condition_summary;

CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(model_completeness) AS mean_completeness,
    AVG(model_coherence) AS mean_coherence,
    AVG(causal_link_accuracy) AS mean_causal_accuracy,
    AVG(feedback_loop_recognition) AS mean_feedback_loop_recognition,
    AVG(boundary_accuracy) AS mean_boundary_accuracy,
    AVG(prediction_error) AS mean_prediction_error,
    AVG(system_understanding_score) AS mean_system_understanding,
    AVG(problem_success) AS success_rate,
    AVG(intervention_choice_accuracy) AS intervention_accuracy,
    AVG(model_revision_score) AS mean_revision_score,
    AVG(transfer_score) AS mean_transfer_score,
    AVG(reasoning_time_ms) AS mean_reasoning_time_ms,
    AVG(confidence) AS mean_confidence,
    AVG(cognitive_load) AS mean_cognitive_load,
    AVG(explanation_quality) AS mean_explanation_quality
FROM mental_models_trials
GROUP BY condition;

DROP VIEW IF EXISTS domain_summary;

CREATE VIEW domain_summary AS
SELECT
    domain,
    COUNT(*) AS n_trials,
    AVG(model_quality_index) AS mean_model_quality_index,
    AVG(prediction_error) AS mean_prediction_error,
    AVG(system_understanding_score) AS mean_system_understanding,
    AVG(problem_success) AS success_rate,
    AVG(transfer_score) AS mean_transfer_score,
    AVG(cognitive_load) AS mean_cognitive_load
FROM mental_models_trials
GROUP BY domain;

DROP VIEW IF EXISTS high_confidence_low_accuracy_cases;

CREATE VIEW high_confidence_low_accuracy_cases AS
SELECT
    participant,
    condition,
    domain,
    scenario_id,
    confidence,
    prediction_error,
    system_understanding_score,
    problem_success,
    intervention_choice_accuracy,
    model_quality_index,
    explanation_quality
FROM mental_models_trials
WHERE confidence >= 7.5
  AND (prediction_error >= 15 OR problem_success = 0 OR intervention_choice_accuracy = 0);

DROP VIEW IF EXISTS strong_model_transfer_cases;

CREATE VIEW strong_model_transfer_cases AS
SELECT
    participant,
    condition,
    domain,
    scenario_id,
    model_quality_index,
    structural_similarity,
    transfer_score,
    prediction_error,
    problem_success
FROM mental_models_trials
WHERE model_quality_index >= 35
  AND transfer_score >= 70;
