-- Decision making in cognitive psychology.
-- Research schema and analytical views.

DROP TABLE IF EXISTS decision_trials;

CREATE TABLE decision_trials (
    participant TEXT NOT NULL,
    condition TEXT NOT NULL,
    domain TEXT NOT NULL,
    trial INTEGER NOT NULL CHECK (trial >= 1),
    scenario_id TEXT NOT NULL,
    option_count INTEGER NOT NULL CHECK (option_count >= 2),
    frame TEXT NOT NULL,
    gain_loss TEXT NOT NULL,
    probability REAL NOT NULL CHECK (probability >= 0 AND probability <= 1),
    payoff REAL NOT NULL,
    reference_point REAL NOT NULL,
    expected_value REAL NOT NULL,
    expected_utility REAL NOT NULL,
    loss_aversion_lambda REAL NOT NULL CHECK (loss_aversion_lambda >= 0),
    probability_weight REAL NOT NULL CHECK (probability_weight >= 0 AND probability_weight <= 1),
    subjective_value REAL NOT NULL,
    evidence_strength REAL NOT NULL,
    drift_rate_proxy REAL NOT NULL,
    decision_threshold REAL NOT NULL CHECK (decision_threshold >= 0),
    choice_risky INTEGER NOT NULL CHECK (choice_risky IN (0, 1)),
    choice_option TEXT NOT NULL,
    optimal_choice INTEGER NOT NULL CHECK (optimal_choice IN (0, 1)),
    accuracy REAL NOT NULL CHECK (accuracy >= 0 AND accuracy <= 1),
    confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
    affective_valence REAL NOT NULL CHECK (affective_valence >= -5 AND affective_valence <= 5),
    cognitive_load REAL NOT NULL CHECK (cognitive_load >= 0 AND cognitive_load <= 10),
    time_pressure REAL NOT NULL CHECK (time_pressure >= 0 AND time_pressure <= 10),
    uncertainty REAL NOT NULL CHECK (uncertainty >= 0 AND uncertainty <= 10),
    response_time_ms REAL NOT NULL CHECK (response_time_ms >= 150),
    feedback_valence REAL NOT NULL CHECK (feedback_valence >= -5 AND feedback_valence <= 5),
    regret REAL NOT NULL CHECK (regret >= 0 AND regret <= 10),
    decision_quality REAL NOT NULL CHECK (decision_quality >= 0 AND decision_quality <= 1),
    ai_recommendation INTEGER NOT NULL CHECK (ai_recommendation IN (0, 1)),
    ai_agreement INTEGER NOT NULL CHECK (ai_agreement IN (0, 1)),
    verification_burden REAL NOT NULL CHECK (verification_burden >= 0 AND verification_burden <= 10),
    high_stakes_flag INTEGER GENERATED ALWAYS AS (
        CASE WHEN domain IN ('legal','medical','finance','policy','environment') THEN 1 ELSE 0 END
    ) VIRTUAL
);

CREATE INDEX idx_decision_participant ON decision_trials(participant);
CREATE INDEX idx_decision_condition ON decision_trials(condition);
CREATE INDEX idx_decision_domain ON decision_trials(domain);
CREATE INDEX idx_decision_frame ON decision_trials(frame);
CREATE INDEX idx_decision_scenario ON decision_trials(scenario_id);
CREATE INDEX idx_decision_ai ON decision_trials(ai_recommendation);

DROP VIEW IF EXISTS condition_summary;

CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(choice_risky) AS risky_choice_rate,
    AVG(optimal_choice) AS optimal_choice_rate,
    AVG(accuracy) AS mean_accuracy,
    AVG(confidence) AS mean_confidence,
    AVG(decision_quality) AS mean_decision_quality,
    AVG(response_time_ms) AS mean_response_time_ms,
    AVG(cognitive_load) AS mean_cognitive_load,
    AVG(time_pressure) AS mean_time_pressure,
    AVG(uncertainty) AS mean_uncertainty,
    AVG(regret) AS mean_regret,
    AVG(ai_agreement) AS ai_agreement_rate,
    AVG(verification_burden) AS mean_verification_burden
FROM decision_trials
GROUP BY condition;

DROP VIEW IF EXISTS frame_gain_loss_summary;

CREATE VIEW frame_gain_loss_summary AS
SELECT
    frame,
    gain_loss,
    COUNT(*) AS n_trials,
    AVG(choice_risky) AS risky_choice_rate,
    AVG(optimal_choice) AS optimal_choice_rate,
    AVG(subjective_value) AS mean_subjective_value,
    AVG(decision_quality) AS mean_decision_quality,
    AVG(response_time_ms) AS mean_response_time_ms
FROM decision_trials
GROUP BY frame, gain_loss;

DROP VIEW IF EXISTS high_uncertainty_low_quality_cases;

CREATE VIEW high_uncertainty_low_quality_cases AS
SELECT
    participant,
    condition,
    domain,
    scenario_id,
    frame,
    gain_loss,
    probability,
    payoff,
    subjective_value,
    choice_risky,
    optimal_choice,
    confidence,
    uncertainty,
    cognitive_load,
    response_time_ms,
    regret,
    decision_quality
FROM decision_trials
WHERE uncertainty >= 7
  AND decision_quality < 0.50;

DROP VIEW IF EXISTS ai_assisted_cases;

CREATE VIEW ai_assisted_cases AS
SELECT
    participant,
    domain,
    scenario_id,
    probability,
    payoff,
    subjective_value,
    evidence_strength,
    confidence,
    uncertainty,
    ai_agreement,
    verification_burden,
    optimal_choice,
    decision_quality
FROM decision_trials
WHERE ai_recommendation = 1;

DROP VIEW IF EXISTS high_verification_burden_cases;

CREATE VIEW high_verification_burden_cases AS
SELECT
    participant,
    domain,
    scenario_id,
    ai_agreement,
    verification_burden,
    uncertainty,
    confidence,
    optimal_choice,
    decision_quality
FROM decision_trials
WHERE ai_recommendation = 1
  AND verification_burden >= 7;
