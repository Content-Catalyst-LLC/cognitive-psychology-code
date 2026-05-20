-- Semantic memory in cognitive psychology.
-- Research schema and analytical views.

DROP TABLE IF EXISTS semantic_memory_trials;

CREATE TABLE semantic_memory_trials (
    participant TEXT NOT NULL,
    condition TEXT NOT NULL,
    trial INTEGER NOT NULL,
    cue_concept TEXT NOT NULL,
    target_concept TEXT NOT NULL,
    category TEXT NOT NULL,
    relation_type TEXT NOT NULL,
    semantic_distance REAL NOT NULL CHECK (semantic_distance >= 0 AND semantic_distance <= 10),
    category_typicality REAL NOT NULL CHECK (category_typicality >= 0 AND category_typicality <= 10),
    feature_overlap REAL NOT NULL CHECK (feature_overlap >= 0 AND feature_overlap <= 10),
    associative_strength REAL NOT NULL CHECK (associative_strength >= 0 AND associative_strength <= 10),
    concept_familiarity REAL NOT NULL CHECK (concept_familiarity >= 0 AND concept_familiarity <= 10),
    concreteness REAL NOT NULL CHECK (concreteness >= 0 AND concreteness <= 10),
    schema_consistency REAL NOT NULL CHECK (schema_consistency >= 0 AND schema_consistency <= 10),
    fact_true INTEGER NOT NULL CHECK (fact_true IN (0, 1)),
    false_association INTEGER NOT NULL CHECK (false_association IN (0, 1)),
    verification_accuracy INTEGER NOT NULL CHECK (verification_accuracy IN (0, 1)),
    category_strength REAL NOT NULL CHECK (category_strength >= 0 AND category_strength <= 10),
    confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 10),
    response_time_ms REAL NOT NULL CHECK (response_time_ms >= 150),
    semantic_support REAL GENERATED ALWAYS AS (
        category_typicality +
        feature_overlap +
        associative_strength +
        concept_familiarity +
        schema_consistency -
        semantic_distance -
        2.0 * false_association
    ) VIRTUAL
);

CREATE INDEX idx_sem_condition ON semantic_memory_trials(condition);
CREATE INDEX idx_sem_participant ON semantic_memory_trials(participant);
CREATE INDEX idx_sem_target ON semantic_memory_trials(target_concept);
CREATE INDEX idx_sem_relation ON semantic_memory_trials(relation_type);
CREATE INDEX idx_sem_category ON semantic_memory_trials(category);

DROP VIEW IF EXISTS condition_summary;

CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(semantic_distance) AS mean_semantic_distance,
    AVG(category_typicality) AS mean_category_typicality,
    AVG(feature_overlap) AS mean_feature_overlap,
    AVG(associative_strength) AS mean_associative_strength,
    AVG(concept_familiarity) AS mean_concept_familiarity,
    AVG(schema_consistency) AS mean_schema_consistency,
    AVG(false_association) AS false_association_rate,
    AVG(fact_true) AS true_fact_rate,
    AVG(verification_accuracy) AS accuracy_rate,
    AVG(category_strength) AS mean_category_strength,
    AVG(confidence) AS mean_confidence,
    AVG(response_time_ms) AS mean_response_time_ms,
    AVG(semantic_support) AS mean_semantic_support
FROM semantic_memory_trials
GROUP BY condition;

DROP VIEW IF EXISTS relation_summary;

CREATE VIEW relation_summary AS
SELECT
    relation_type,
    COUNT(*) AS n_trials,
    AVG(semantic_distance) AS mean_semantic_distance,
    AVG(associative_strength) AS mean_associative_strength,
    AVG(fact_true) AS true_fact_rate,
    AVG(false_association) AS false_association_rate,
    AVG(verification_accuracy) AS accuracy_rate,
    AVG(response_time_ms) AS mean_response_time_ms
FROM semantic_memory_trials
GROUP BY relation_type;

DROP VIEW IF EXISTS false_semantic_association_cases;

CREATE VIEW false_semantic_association_cases AS
SELECT
    participant,
    condition,
    cue_concept,
    target_concept,
    category,
    relation_type,
    semantic_distance,
    associative_strength,
    schema_consistency,
    fact_true,
    false_association,
    verification_accuracy,
    confidence,
    response_time_ms
FROM semantic_memory_trials
WHERE false_association = 1
   OR (fact_true = 0 AND associative_strength >= 7);
