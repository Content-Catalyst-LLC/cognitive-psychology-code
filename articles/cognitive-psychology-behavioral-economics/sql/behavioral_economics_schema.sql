-- Cognitive psychology and behavioral economics.
-- Research schema and analytical views.

DROP TABLE IF EXISTS behavioral_economics_trials;

CREATE TABLE behavioral_economics_trials (
    participant TEXT NOT NULL,
    condition TEXT NOT NULL,
    trial INTEGER NOT NULL,
    choice_domain TEXT NOT NULL,
    gain_loss_frame TEXT NOT NULL,
    reference_point REAL NOT NULL,
    outcome_amount REAL NOT NULL,
    probability REAL NOT NULL CHECK (probability >= 0 AND probability <= 1),
    delay_days REAL NOT NULL CHECK (delay_days >= 0),
    cognitive_load REAL NOT NULL CHECK (cognitive_load >= 0 AND cognitive_load <= 10),
    attention_score REAL NOT NULL CHECK (attention_score >= 0 AND attention_score <= 10),
    default_present INTEGER NOT NULL CHECK (default_present IN (0, 1)),
    social_norm_strength REAL NOT NULL CHECK (social_norm_strength >= 0 AND social_norm_strength <= 10),
    loss_aversion_lambda REAL NOT NULL CHECK (loss_aversion_lambda >= 1),
    risky_choice INTEGER NOT NULL CHECK (risky_choice IN (0, 1)),
    default_accepted INTEGER NOT NULL CHECK (default_accepted IN (0, 1)),
    willingness_to_pay REAL NOT NULL CHECK (willingness_to_pay >= 0),
    decision_time_ms REAL NOT NULL CHECK (decision_time_ms >= 150),
    behavioral_pressure REAL GENERATED ALWAYS AS (
        cognitive_load +
        0.5 * social_norm_strength +
        1.5 * default_present -
        0.4 * attention_score
    ) VIRTUAL
);

CREATE INDEX idx_behavior_condition ON behavioral_economics_trials(condition);
CREATE INDEX idx_behavior_participant ON behavioral_economics_trials(participant);
CREATE INDEX idx_behavior_domain ON behavioral_economics_trials(choice_domain);
CREATE INDEX idx_behavior_frame ON behavioral_economics_trials(gain_loss_frame);

DROP VIEW IF EXISTS condition_summary;

CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(cognitive_load) AS mean_cognitive_load,
    AVG(attention_score) AS mean_attention,
    AVG(social_norm_strength) AS mean_social_norm_strength,
    AVG(loss_aversion_lambda) AS mean_loss_aversion_lambda,
    AVG(risky_choice) AS risky_choice_rate,
    AVG(default_accepted) AS default_acceptance_rate,
    AVG(willingness_to_pay) AS mean_willingness_to_pay,
    AVG(decision_time_ms) AS mean_decision_time_ms,
    AVG(behavioral_pressure) AS mean_behavioral_pressure
FROM behavioral_economics_trials
GROUP BY condition;

DROP VIEW IF EXISTS framing_summary;

CREATE VIEW framing_summary AS
SELECT
    gain_loss_frame,
    COUNT(*) AS n_trials,
    AVG(outcome_amount) AS mean_outcome_amount,
    AVG(probability) AS mean_probability,
    AVG(cognitive_load) AS mean_cognitive_load,
    AVG(risky_choice) AS risky_choice_rate,
    AVG(willingness_to_pay) AS mean_wtp,
    AVG(decision_time_ms) AS mean_decision_time_ms
FROM behavioral_economics_trials
GROUP BY gain_loss_frame;

DROP VIEW IF EXISTS high_pressure_choices;

CREATE VIEW high_pressure_choices AS
SELECT
    participant,
    condition,
    trial,
    choice_domain,
    gain_loss_frame,
    cognitive_load,
    attention_score,
    social_norm_strength,
    default_present,
    behavioral_pressure,
    risky_choice,
    default_accepted,
    willingness_to_pay,
    decision_time_ms
FROM behavioral_economics_trials
WHERE behavioral_pressure >= 8
   OR cognitive_load >= 8
   OR decision_time_ms >= 5000;
