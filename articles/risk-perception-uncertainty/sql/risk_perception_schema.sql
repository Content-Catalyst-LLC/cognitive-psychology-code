-- Risk perception and uncertainty.
-- Research schema and analytical views.

DROP TABLE IF EXISTS risk_perception_trials;

CREATE TABLE risk_perception_trials (
    participant TEXT NOT NULL,
    condition TEXT NOT NULL,
    domain TEXT NOT NULL,
    trial INTEGER NOT NULL CHECK (trial >= 1),
    scenario_id TEXT NOT NULL,
    objective_probability REAL NOT NULL CHECK (objective_probability >= 0 AND objective_probability <= 1),
    subjective_probability REAL NOT NULL CHECK (subjective_probability >= 0 AND subjective_probability <= 1),
    consequence_rating REAL NOT NULL CHECK (consequence_rating >= 0 AND consequence_rating <= 10),
    affect_rating REAL NOT NULL CHECK (affect_rating >= 0 AND affect_rating <= 10),
    dread_rating REAL NOT NULL CHECK (dread_rating >= 0 AND dread_rating <= 10),
    familiarity_rating REAL NOT NULL CHECK (familiarity_rating >= 0 AND familiarity_rating <= 10),
    controllability_rating REAL NOT NULL CHECK (controllability_rating >= 0 AND controllability_rating <= 10),
    trust_rating REAL NOT NULL CHECK (trust_rating >= 0 AND trust_rating <= 10),
    ambiguity_rating REAL NOT NULL CHECK (ambiguity_rating >= 0 AND ambiguity_rating <= 10),
    communication_clarity REAL NOT NULL CHECK (communication_clarity >= 0 AND communication_clarity <= 10),
    perceived_benefit REAL NOT NULL CHECK (perceived_benefit >= 0 AND perceived_benefit <= 10),
    perceived_risk REAL NOT NULL CHECK (perceived_risk >= 0 AND perceived_risk <= 10),
    choose_safe INTEGER NOT NULL CHECK (choose_safe IN (0, 1)),
    protective_action INTEGER NOT NULL CHECK (protective_action IN (0, 1)),
    rt_ms REAL NOT NULL CHECK (rt_ms >= 150),
    confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 10),
    probability_distortion REAL GENERATED ALWAYS AS (subjective_probability - objective_probability) VIRTUAL,
    risk_benefit_gap REAL GENERATED ALWAYS AS (perceived_risk - perceived_benefit) VIRTUAL
);

CREATE INDEX idx_rp_participant ON risk_perception_trials(participant);
CREATE INDEX idx_rp_condition ON risk_perception_trials(condition);
CREATE INDEX idx_rp_domain ON risk_perception_trials(domain);
CREATE INDEX idx_rp_scenario ON risk_perception_trials(scenario_id);

DROP VIEW IF EXISTS condition_summary;

CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(objective_probability) AS mean_objective_probability,
    AVG(subjective_probability) AS mean_subjective_probability,
    AVG(probability_distortion) AS mean_probability_distortion,
    AVG(consequence_rating) AS mean_consequence,
    AVG(affect_rating) AS mean_affect,
    AVG(dread_rating) AS mean_dread,
    AVG(controllability_rating) AS mean_controllability,
    AVG(trust_rating) AS mean_trust,
    AVG(ambiguity_rating) AS mean_ambiguity,
    AVG(communication_clarity) AS mean_clarity,
    AVG(perceived_benefit) AS mean_benefit,
    AVG(perceived_risk) AS mean_perceived_risk,
    AVG(choose_safe) AS safe_choice_rate,
    AVG(protective_action) AS protective_action_rate,
    AVG(rt_ms) AS mean_rt_ms,
    AVG(confidence) AS mean_confidence
FROM risk_perception_trials
GROUP BY condition;

DROP VIEW IF EXISTS domain_summary;

CREATE VIEW domain_summary AS
SELECT
    domain,
    COUNT(*) AS n_trials,
    AVG(perceived_risk) AS mean_perceived_risk,
    AVG(affect_rating) AS mean_affect,
    AVG(dread_rating) AS mean_dread,
    AVG(ambiguity_rating) AS mean_ambiguity,
    AVG(trust_rating) AS mean_trust,
    AVG(choose_safe) AS safe_choice_rate,
    AVG(protective_action) AS protective_action_rate
FROM risk_perception_trials
GROUP BY domain;

DROP VIEW IF EXISTS high_affect_probability_distortion_cases;

CREATE VIEW high_affect_probability_distortion_cases AS
SELECT
    participant,
    condition,
    domain,
    scenario_id,
    objective_probability,
    subjective_probability,
    probability_distortion,
    affect_rating,
    dread_rating,
    perceived_risk,
    choose_safe,
    protective_action
FROM risk_perception_trials
WHERE affect_rating >= 7
  AND probability_distortion >= 0.10;

DROP VIEW IF EXISTS high_risk_low_action_cases;

CREATE VIEW high_risk_low_action_cases AS
SELECT
    participant,
    condition,
    domain,
    scenario_id,
    perceived_risk,
    trust_rating,
    ambiguity_rating,
    communication_clarity,
    controllability_rating,
    protective_action,
    confidence
FROM risk_perception_trials
WHERE perceived_risk >= 7
  AND protective_action = 0;
