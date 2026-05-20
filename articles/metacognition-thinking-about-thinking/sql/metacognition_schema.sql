-- Metacognition in cognitive psychology.
-- Research schema and analytical views.

DROP TABLE IF EXISTS metacognition_trials;

CREATE TABLE metacognition_trials (
    participant TEXT NOT NULL,
    condition TEXT NOT NULL,
    trial INTEGER NOT NULL,
    task_id TEXT NOT NULL,
    domain TEXT NOT NULL,
    task_difficulty REAL NOT NULL CHECK (task_difficulty >= 0 AND task_difficulty <= 10),
    evidence_quality REAL NOT NULL CHECK (evidence_quality >= 0 AND evidence_quality <= 10),
    confidence_rating REAL NOT NULL CHECK (confidence_rating >= 0 AND confidence_rating <= 1),
    uncertainty_rating REAL NOT NULL CHECK (uncertainty_rating >= 0 AND uncertainty_rating <= 1),
    actual_accuracy INTEGER NOT NULL CHECK (actual_accuracy IN (0, 1)),
    judgment_of_learning REAL NOT NULL CHECK (judgment_of_learning >= 0 AND judgment_of_learning <= 1),
    feeling_of_knowing REAL NOT NULL CHECK (feeling_of_knowing >= 0 AND feeling_of_knowing <= 1),
    strategy_shift INTEGER NOT NULL CHECK (strategy_shift IN (0, 1)),
    review_choice INTEGER NOT NULL CHECK (review_choice IN (0, 1)),
    feedback_used INTEGER NOT NULL CHECK (feedback_used IN (0, 1)),
    study_time_seconds REAL NOT NULL CHECK (study_time_seconds >= 0),
    response_time_ms REAL NOT NULL CHECK (response_time_ms >= 150),
    metacognitive_regulation_score REAL NOT NULL CHECK (metacognitive_regulation_score >= 0 AND metacognitive_regulation_score <= 10),
    calibration_error REAL GENERATED ALWAYS AS (ABS(confidence_rating - actual_accuracy)) VIRTUAL,
    signed_calibration REAL GENERATED ALWAYS AS (confidence_rating - actual_accuracy) VIRTUAL
);

CREATE INDEX idx_mc_condition ON metacognition_trials(condition);
CREATE INDEX idx_mc_participant ON metacognition_trials(participant);
CREATE INDEX idx_mc_task ON metacognition_trials(task_id);
CREATE INDEX idx_mc_domain ON metacognition_trials(domain);

DROP VIEW IF EXISTS condition_summary;

CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(task_difficulty) AS mean_difficulty,
    AVG(evidence_quality) AS mean_evidence_quality,
    AVG(confidence_rating) AS mean_confidence,
    AVG(uncertainty_rating) AS mean_uncertainty,
    AVG(actual_accuracy) AS accuracy_rate,
    AVG(calibration_error) AS mean_calibration_error,
    AVG(signed_calibration) AS mean_signed_calibration,
    AVG(strategy_shift) AS strategy_shift_rate,
    AVG(review_choice) AS review_choice_rate,
    AVG(feedback_used) AS feedback_use_rate,
    AVG(study_time_seconds) AS mean_study_time_seconds,
    AVG(response_time_ms) AS mean_response_time_ms,
    AVG(metacognitive_regulation_score) AS mean_regulation_score
FROM metacognition_trials
GROUP BY condition;

DROP VIEW IF EXISTS overconfidence_cases;

CREATE VIEW overconfidence_cases AS
SELECT
    participant,
    condition,
    task_id,
    domain,
    task_difficulty,
    evidence_quality,
    confidence_rating,
    actual_accuracy,
    signed_calibration,
    calibration_error,
    strategy_shift,
    review_choice,
    feedback_used,
    metacognitive_regulation_score
FROM metacognition_trials
WHERE signed_calibration >= 0.50
   OR (confidence_rating >= 0.75 AND actual_accuracy = 0);

DROP VIEW IF EXISTS adaptive_regulation_cases;

CREATE VIEW adaptive_regulation_cases AS
SELECT
    participant,
    condition,
    task_id,
    domain,
    task_difficulty,
    uncertainty_rating,
    confidence_rating,
    actual_accuracy,
    calibration_error,
    strategy_shift,
    review_choice,
    feedback_used,
    study_time_seconds,
    metacognitive_regulation_score
FROM metacognition_trials
WHERE uncertainty_rating >= 0.50
  AND (strategy_shift = 1 OR review_choice = 1 OR feedback_used = 1);
