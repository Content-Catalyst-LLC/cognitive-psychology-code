-- Heuristics in cognitive psychology.
-- Research schema and analytical views.

DROP TABLE IF EXISTS heuristics_trials;

CREATE TABLE heuristics_trials (
    participant TEXT NOT NULL,
    condition TEXT NOT NULL,
    domain TEXT NOT NULL,
    trial INTEGER NOT NULL CHECK (trial >= 1),
    scenario_id TEXT NOT NULL,
    heuristic_type TEXT NOT NULL,
    anchor_value REAL NOT NULL CHECK (anchor_value >= 0 AND anchor_value <= 100),
    adjustment REAL NOT NULL,
    recall_ease REAL NOT NULL CHECK (recall_ease >= 0 AND recall_ease <= 10),
    representativeness REAL NOT NULL CHECK (representativeness >= 0 AND representativeness <= 10),
    base_rate REAL NOT NULL CHECK (base_rate >= 0 AND base_rate <= 1),
    base_rate_use REAL NOT NULL CHECK (base_rate_use >= 0 AND base_rate_use <= 1),
    recognition_strength REAL NOT NULL CHECK (recognition_strength >= 0 AND recognition_strength <= 10),
    fluency REAL NOT NULL CHECK (fluency >= 0 AND fluency <= 10),
    affective_valence REAL NOT NULL CHECK (affective_valence >= -5 AND affective_valence <= 5),
    cue_validity REAL NOT NULL CHECK (cue_validity >= 0 AND cue_validity <= 1),
    cue_count INTEGER NOT NULL CHECK (cue_count >= 1),
    information_cost REAL NOT NULL CHECK (information_cost >= 0 AND information_cost <= 10),
    time_pressure REAL NOT NULL CHECK (time_pressure >= 0 AND time_pressure <= 10),
    cognitive_load REAL NOT NULL CHECK (cognitive_load >= 0 AND cognitive_load <= 10),
    strategy_complexity REAL NOT NULL CHECK (strategy_complexity >= 0 AND strategy_complexity <= 10),
    subjective_effort REAL NOT NULL CHECK (subjective_effort >= 0 AND subjective_effort <= 10),
    judged_probability REAL NOT NULL CHECK (judged_probability >= 0 AND judged_probability <= 1),
    true_probability REAL NOT NULL CHECK (true_probability >= 0 AND true_probability <= 1),
    estimate REAL NOT NULL CHECK (estimate >= 0 AND estimate <= 100),
    true_value REAL NOT NULL CHECK (true_value >= 0 AND true_value <= 100),
    choice_binary INTEGER NOT NULL CHECK (choice_binary IN (0, 1)),
    correct INTEGER NOT NULL CHECK (correct IN (0, 1)),
    rt_ms REAL NOT NULL CHECK (rt_ms >= 150),
    confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 10),
    calibration_error REAL NOT NULL CHECK (calibration_error >= 0 AND calibration_error <= 1),
    bias_magnitude REAL NOT NULL CHECK (bias_magnitude >= 0),
    adaptive_fit REAL NOT NULL CHECK (adaptive_fit >= -1 AND adaptive_fit <= 1),
    anchor_bias REAL GENERATED ALWAYS AS (estimate - true_value) VIRTUAL,
    probability_bias REAL GENERATED ALWAYS AS (judged_probability - true_probability) VIRTUAL
);

CREATE INDEX idx_h_participant ON heuristics_trials(participant);
CREATE INDEX idx_h_condition ON heuristics_trials(condition);
CREATE INDEX idx_h_domain ON heuristics_trials(domain);
CREATE INDEX idx_h_type ON heuristics_trials(heuristic_type);
CREATE INDEX idx_h_scenario ON heuristics_trials(scenario_id);

DROP VIEW IF EXISTS condition_summary;

CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(judged_probability) AS mean_judged_probability,
    AVG(true_probability) AS mean_true_probability,
    AVG(estimate) AS mean_estimate,
    AVG(true_value) AS mean_true_value,
    AVG(choice_binary) AS choice_rate,
    AVG(correct) AS correct_rate,
    AVG(rt_ms) AS mean_rt_ms,
    AVG(confidence) AS mean_confidence,
    AVG(calibration_error) AS mean_calibration_error,
    AVG(bias_magnitude) AS mean_bias_magnitude,
    AVG(adaptive_fit) AS mean_adaptive_fit,
    AVG(subjective_effort) AS mean_effort,
    AVG(cue_count) AS mean_cue_count
FROM heuristics_trials
GROUP BY condition;

DROP VIEW IF EXISTS heuristic_summary;

CREATE VIEW heuristic_summary AS
SELECT
    heuristic_type,
    COUNT(*) AS n_trials,
    AVG(correct) AS correct_rate,
    AVG(subjective_effort) AS mean_effort,
    AVG(rt_ms) AS mean_rt_ms,
    AVG(calibration_error) AS mean_calibration_error,
    AVG(bias_magnitude) AS mean_bias_magnitude,
    AVG(adaptive_fit) AS mean_adaptive_fit
FROM heuristics_trials
GROUP BY heuristic_type;

DROP VIEW IF EXISTS high_anchor_bias_cases;

CREATE VIEW high_anchor_bias_cases AS
SELECT
    participant,
    condition,
    domain,
    scenario_id,
    anchor_value,
    estimate,
    true_value,
    anchor_bias,
    adjustment,
    subjective_effort,
    confidence
FROM heuristics_trials
WHERE condition = 'anchoring'
  AND ABS(anchor_bias) >= 20;

DROP VIEW IF EXISTS high_availability_error_cases;

CREATE VIEW high_availability_error_cases AS
SELECT
    participant,
    condition,
    domain,
    scenario_id,
    recall_ease,
    judged_probability,
    true_probability,
    probability_bias,
    calibration_error,
    confidence
FROM heuristics_trials
WHERE condition = 'availability'
  AND calibration_error >= 0.20;

DROP VIEW IF EXISTS adaptive_heuristic_cases;

CREATE VIEW adaptive_heuristic_cases AS
SELECT
    participant,
    condition,
    domain,
    heuristic_type,
    cue_validity,
    cue_count,
    information_cost,
    time_pressure,
    correct,
    adaptive_fit,
    rt_ms,
    subjective_effort
FROM heuristics_trials
WHERE adaptive_fit > 0
  AND correct = 1;
