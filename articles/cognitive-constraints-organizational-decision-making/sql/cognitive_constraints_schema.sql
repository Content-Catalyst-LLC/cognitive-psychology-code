-- Cognitive constraints in organizational decision making.
-- Research schema and analytical views.
--
-- This SQL is intentionally portable and should run with minor adjustments
-- in SQLite, PostgreSQL, DuckDB, or similar relational engines.

DROP TABLE IF EXISTS organizational_decision_trials;

CREATE TABLE organizational_decision_trials (
    participant TEXT NOT NULL,
    unit TEXT NOT NULL,
    condition TEXT NOT NULL,
    trial INTEGER NOT NULL,
    info_load REAL NOT NULL CHECK (info_load >= 0 AND info_load <= 10),
    attention_score REAL NOT NULL CHECK (attention_score >= 0 AND attention_score <= 10),
    uncertainty_level REAL NOT NULL CHECK (uncertainty_level >= 0 AND uncertainty_level <= 10),
    coordination_load REAL NOT NULL CHECK (coordination_load >= 0 AND coordination_load <= 10),
    institutional_pressure REAL NOT NULL CHECK (institutional_pressure >= 0 AND institutional_pressure <= 10),
    feedback_delay REAL NOT NULL CHECK (feedback_delay >= 0 AND feedback_delay <= 10),
    psychological_safety REAL NOT NULL CHECK (psychological_safety >= 0 AND psychological_safety <= 10),
    dissent_present INTEGER NOT NULL CHECK (dissent_present IN (0, 1)),
    automation_reliance REAL NOT NULL CHECK (automation_reliance >= 0 AND automation_reliance <= 10),
    decision_quality REAL NOT NULL CHECK (decision_quality >= 0 AND decision_quality <= 100),
    chose_satisficing INTEGER NOT NULL CHECK (chose_satisficing IN (0, 1)),
    response_time_ms REAL NOT NULL CHECK (response_time_ms >= 150),
    cognitive_burden REAL GENERATED ALWAYS AS (
        info_load +
        uncertainty_level +
        coordination_load +
        institutional_pressure +
        0.5 * feedback_delay +
        0.25 * automation_reliance -
        0.55 * psychological_safety -
        0.9 * dissent_present
    ) VIRTUAL
);

CREATE INDEX idx_trials_condition ON organizational_decision_trials(condition);
CREATE INDEX idx_trials_participant ON organizational_decision_trials(participant);
CREATE INDEX idx_trials_unit ON organizational_decision_trials(unit);

DROP VIEW IF EXISTS condition_summary;

CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS participants,
    AVG(info_load) AS mean_info_load,
    AVG(attention_score) AS mean_attention,
    AVG(uncertainty_level) AS mean_uncertainty,
    AVG(coordination_load) AS mean_coordination,
    AVG(institutional_pressure) AS mean_pressure,
    AVG(feedback_delay) AS mean_feedback_delay,
    AVG(psychological_safety) AS mean_safety,
    AVG(dissent_present) AS dissent_rate,
    AVG(automation_reliance) AS mean_automation,
    AVG(cognitive_burden) AS mean_cognitive_burden,
    AVG(decision_quality) AS mean_decision_quality,
    AVG(chose_satisficing) AS satisficing_rate,
    AVG(response_time_ms) AS mean_response_time_ms
FROM organizational_decision_trials
GROUP BY condition;

DROP VIEW IF EXISTS high_burden_low_quality_trials;

CREATE VIEW high_burden_low_quality_trials AS
SELECT
    participant,
    unit,
    condition,
    trial,
    cognitive_burden,
    decision_quality,
    chose_satisficing,
    response_time_ms
FROM organizational_decision_trials
WHERE cognitive_burden >= 20
  AND decision_quality <= 60;

DROP VIEW IF EXISTS unit_risk_profile;

CREATE VIEW unit_risk_profile AS
SELECT
    unit,
    COUNT(*) AS n_trials,
    AVG(cognitive_burden) AS mean_cognitive_burden,
    AVG(decision_quality) AS mean_decision_quality,
    AVG(chose_satisficing) AS satisficing_rate,
    AVG(psychological_safety) AS mean_psychological_safety,
    AVG(dissent_present) AS dissent_rate
FROM organizational_decision_trials
GROUP BY unit;
