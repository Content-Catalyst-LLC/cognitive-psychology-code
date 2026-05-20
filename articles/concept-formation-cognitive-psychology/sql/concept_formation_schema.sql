-- Concept formation in cognitive psychology.
-- Research schema and analytical views.

DROP TABLE IF EXISTS concept_formation_trials;

CREATE TABLE concept_formation_trials (
    participant TEXT NOT NULL,
    condition TEXT NOT NULL,
    trial INTEGER NOT NULL,
    stimulus_id TEXT NOT NULL,
    category_label TEXT NOT NULL,
    prototype_distance REAL NOT NULL CHECK (prototype_distance >= 0 AND prototype_distance <= 10),
    nearest_competing_distance REAL NOT NULL CHECK (nearest_competing_distance >= 0 AND nearest_competing_distance <= 10),
    exemplar_similarity REAL NOT NULL CHECK (exemplar_similarity >= 0 AND exemplar_similarity <= 10),
    feature_diagnosticity REAL NOT NULL CHECK (feature_diagnosticity >= 0 AND feature_diagnosticity <= 10),
    feature_overlap REAL NOT NULL CHECK (feature_overlap >= 0 AND feature_overlap <= 10),
    boundary_ambiguity REAL NOT NULL CHECK (boundary_ambiguity >= 0 AND boundary_ambiguity <= 10),
    rule_consistency REAL NOT NULL CHECK (rule_consistency >= 0 AND rule_consistency <= 10),
    feedback_available INTEGER NOT NULL CHECK (feedback_available IN (0, 1)),
    category_accuracy INTEGER NOT NULL CHECK (category_accuracy IN (0, 1)),
    generalization_score REAL NOT NULL CHECK (generalization_score >= 0 AND generalization_score <= 100),
    discrimination_score REAL NOT NULL CHECK (discrimination_score >= 0 AND discrimination_score <= 100),
    abstraction_quality REAL NOT NULL CHECK (abstraction_quality >= 0 AND abstraction_quality <= 10),
    conceptual_flexibility REAL NOT NULL CHECK (conceptual_flexibility >= 0 AND conceptual_flexibility <= 10),
    confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 10),
    response_time_ms REAL NOT NULL CHECK (response_time_ms >= 150),
    concept_learning_support REAL GENERATED ALWAYS AS (
        exemplar_similarity +
        feature_diagnosticity +
        rule_consistency +
        abstraction_quality +
        conceptual_flexibility +
        feedback_available -
        prototype_distance -
        boundary_ambiguity
    ) VIRTUAL
);

CREATE INDEX idx_cf_condition ON concept_formation_trials(condition);
CREATE INDEX idx_cf_participant ON concept_formation_trials(participant);
CREATE INDEX idx_cf_stimulus ON concept_formation_trials(stimulus_id);
CREATE INDEX idx_cf_category ON concept_formation_trials(category_label);

DROP VIEW IF EXISTS condition_summary;

CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(prototype_distance) AS mean_prototype_distance,
    AVG(nearest_competing_distance) AS mean_competing_distance,
    AVG(exemplar_similarity) AS mean_exemplar_similarity,
    AVG(feature_diagnosticity) AS mean_feature_diagnosticity,
    AVG(feature_overlap) AS mean_feature_overlap,
    AVG(boundary_ambiguity) AS mean_boundary_ambiguity,
    AVG(rule_consistency) AS mean_rule_consistency,
    AVG(feedback_available) AS feedback_rate,
    AVG(category_accuracy) AS accuracy_rate,
    AVG(generalization_score) AS mean_generalization_score,
    AVG(discrimination_score) AS mean_discrimination_score,
    AVG(abstraction_quality) AS mean_abstraction_quality,
    AVG(conceptual_flexibility) AS mean_conceptual_flexibility,
    AVG(confidence) AS mean_confidence,
    AVG(response_time_ms) AS mean_response_time_ms,
    AVG(concept_learning_support) AS mean_concept_learning_support
FROM concept_formation_trials
GROUP BY condition;

DROP VIEW IF EXISTS category_summary;

CREATE VIEW category_summary AS
SELECT
    category_label,
    COUNT(*) AS n_trials,
    AVG(category_accuracy) AS accuracy_rate,
    AVG(generalization_score) AS mean_generalization_score,
    AVG(discrimination_score) AS mean_discrimination_score,
    AVG(response_time_ms) AS mean_response_time_ms
FROM concept_formation_trials
GROUP BY category_label;

DROP VIEW IF EXISTS boundary_cases;

CREATE VIEW boundary_cases AS
SELECT
    participant,
    condition,
    stimulus_id,
    category_label,
    prototype_distance,
    nearest_competing_distance,
    exemplar_similarity,
    feature_diagnosticity,
    boundary_ambiguity,
    category_accuracy,
    generalization_score,
    discrimination_score,
    confidence,
    response_time_ms
FROM concept_formation_trials
WHERE boundary_ambiguity >= 7
   OR ABS(prototype_distance - nearest_competing_distance) <= 0.75;
