-- Cognitive biases in decision making.
-- Research schema and analytical views.

DROP TABLE IF EXISTS cognitive_bias_trials;

CREATE TABLE cognitive_bias_trials (
    participant TEXT NOT NULL,
    condition TEXT NOT NULL,
    domain TEXT NOT NULL,
    trial INTEGER NOT NULL CHECK (trial >= 1),
    scenario_id TEXT NOT NULL,
    bias_type TEXT NOT NULL,
    frame TEXT NOT NULL,
    gain_loss TEXT NOT NULL,
    anchor_value REAL NOT NULL CHECK (anchor_value >= 0 AND anchor_value <= 100),
    base_rate REAL NOT NULL CHECK (base_rate >= 0 AND base_rate <= 1),
    representativeness REAL NOT NULL CHECK (representativeness >= 0 AND representativeness <= 10),
    evidence_valence REAL NOT NULL CHECK (evidence_valence >= -5 AND evidence_valence <= 5),
    confirmation_congruence REAL NOT NULL CHECK (confirmation_congruence >= 0 AND confirmation_congruence <= 1),
    prior_belief REAL NOT NULL CHECK (prior_belief >= 0 AND prior_belief <= 1),
    confidence_rating REAL NOT NULL CHECK (confidence_rating >= 0 AND confidence_rating <= 1),
    actual_accuracy REAL NOT NULL CHECK (actual_accuracy >= 0 AND actual_accuracy <= 1),
    calibration_error REAL NOT NULL CHECK (calibration_error >= 0 AND calibration_error <= 1),
    overconfidence REAL NOT NULL CHECK (overconfidence >= -1 AND overconfidence <= 1),
    probability REAL NOT NULL CHECK (probability >= 0 AND probability <= 1),
    payoff REAL NOT NULL,
    loss_aversion_lambda REAL NOT NULL CHECK (loss_aversion_lambda >= 0),
    probability_weight REAL NOT NULL CHECK (probability_weight >= 0 AND probability_weight <= 1),
    subjective_value REAL NOT NULL,
    chose_risky INTEGER NOT NULL CHECK (chose_risky IN (0, 1)),
    choice_binary INTEGER NOT NULL CHECK (choice_binary IN (0, 1)),
    correct INTEGER NOT NULL CHECK (correct IN (0, 1)),
    response_time_ms REAL NOT NULL CHECK (response_time_ms >= 150),
    cognitive_load REAL NOT NULL CHECK (cognitive_load >= 0 AND cognitive_load <= 10),
    time_pressure REAL NOT NULL CHECK (time_pressure >= 0 AND time_pressure <= 10),
    debiasing_condition TEXT NOT NULL,
    decision_quality REAL NOT NULL CHECK (decision_quality >= 0 AND decision_quality <= 1),
    institutional_review_flag INTEGER NOT NULL CHECK (institutional_review_flag IN (0, 1)),
    high_stakes_flag INTEGER GENERATED ALWAYS AS (
        CASE WHEN domain IN ('legal','medical','finance','policy') THEN 1 ELSE 0 END
    ) VIRTUAL
);

CREATE INDEX idx_cb_participant ON cognitive_bias_trials(participant);
CREATE INDEX idx_cb_condition ON cognitive_bias_trials(condition);
CREATE INDEX idx_cb_domain ON cognitive_bias_trials(domain);
CREATE INDEX idx_cb_bias_type ON cognitive_bias_trials(bias_type);
CREATE INDEX idx_cb_debiasing ON cognitive_bias_trials(debiasing_condition);
CREATE INDEX idx_cb_scenario ON cognitive_bias_trials(scenario_id);

DROP VIEW IF EXISTS condition_summary;

CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(confidence_rating) AS mean_confidence,
    AVG(actual_accuracy) AS mean_accuracy,
    AVG(calibration_error) AS mean_calibration_error,
    AVG(overconfidence) AS mean_overconfidence,
    AVG(chose_risky) AS risky_choice_rate,
    AVG(correct) AS correct_rate,
    AVG(decision_quality) AS mean_decision_quality,
    AVG(institutional_review_flag) AS review_flag_rate,
    AVG(response_time_ms) AS mean_response_time_ms
FROM cognitive_bias_trials
GROUP BY condition;

DROP VIEW IF EXISTS bias_type_summary;

CREATE VIEW bias_type_summary AS
SELECT
    bias_type,
    COUNT(*) AS n_trials,
    AVG(correct) AS correct_rate,
    AVG(calibration_error) AS mean_calibration_error,
    AVG(overconfidence) AS mean_overconfidence,
    AVG(chose_risky) AS risky_choice_rate,
    AVG(decision_quality) AS mean_decision_quality,
    AVG(institutional_review_flag) AS review_flag_rate
FROM cognitive_bias_trials
GROUP BY bias_type;

DROP VIEW IF EXISTS debiasing_summary;

CREATE VIEW debiasing_summary AS
SELECT
    debiasing_condition,
    COUNT(*) AS n_trials,
    AVG(calibration_error) AS mean_calibration_error,
    AVG(overconfidence) AS mean_overconfidence,
    AVG(correct) AS correct_rate,
    AVG(decision_quality) AS mean_decision_quality,
    AVG(institutional_review_flag) AS review_flag_rate
FROM cognitive_bias_trials
GROUP BY debiasing_condition;

DROP VIEW IF EXISTS high_risk_bias_cases;

CREATE VIEW high_risk_bias_cases AS
SELECT
    participant,
    condition,
    domain,
    scenario_id,
    bias_type,
    confidence_rating,
    actual_accuracy,
    calibration_error,
    overconfidence,
    cognitive_load,
    time_pressure,
    debiasing_condition,
    decision_quality,
    institutional_review_flag
FROM cognitive_bias_trials
WHERE high_stakes_flag = 1
  AND (calibration_error >= 0.20 OR overconfidence >= 0.20 OR decision_quality < 0.50);

DROP VIEW IF EXISTS confirmation_bias_cases;

CREATE VIEW confirmation_bias_cases AS
SELECT
    participant,
    domain,
    scenario_id,
    prior_belief,
    evidence_valence,
    confirmation_congruence,
    confidence_rating,
    actual_accuracy,
    decision_quality,
    debiasing_condition
FROM cognitive_bias_trials
WHERE bias_type = 'confirmation'
  AND confirmation_congruence >= 0.70;

DROP VIEW IF EXISTS debiasing_improvement_candidates;

CREATE VIEW debiasing_improvement_candidates AS
SELECT
    participant,
    condition,
    domain,
    bias_type,
    calibration_error,
    overconfidence,
    decision_quality,
    debiasing_condition,
    institutional_review_flag
FROM cognitive_bias_trials
WHERE debiasing_condition <> 'none'
ORDER BY decision_quality DESC;
