-- Analogical reasoning and knowledge transfer.
-- Research schema and analytical views.

DROP TABLE IF EXISTS analogical_reasoning_trials;

CREATE TABLE analogical_reasoning_trials (
    participant TEXT NOT NULL,
    condition TEXT NOT NULL,
    source_id TEXT NOT NULL,
    target_id TEXT NOT NULL,
    trial INTEGER NOT NULL,
    source_familiarity REAL NOT NULL CHECK (source_familiarity >= 0 AND source_familiarity <= 10),
    target_novelty REAL NOT NULL CHECK (target_novelty >= 0 AND target_novelty <= 10),
    surface_similarity REAL NOT NULL CHECK (surface_similarity >= 0 AND surface_similarity <= 10),
    structural_similarity REAL NOT NULL CHECK (structural_similarity >= 0 AND structural_similarity <= 10),
    relational_complexity REAL NOT NULL CHECK (relational_complexity >= 0 AND relational_complexity <= 10),
    working_memory_load REAL NOT NULL CHECK (working_memory_load >= 0 AND working_memory_load <= 10),
    analogical_cue INTEGER NOT NULL CHECK (analogical_cue IN (0, 1)),
    mapping_accuracy INTEGER NOT NULL CHECK (mapping_accuracy IN (0, 1)),
    transfer_success INTEGER NOT NULL CHECK (transfer_success IN (0, 1)),
    inference_quality REAL NOT NULL CHECK (inference_quality >= 0 AND inference_quality <= 100),
    schema_abstraction REAL NOT NULL CHECK (schema_abstraction >= 0 AND schema_abstraction <= 10),
    confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 10),
    response_time_ms REAL NOT NULL CHECK (response_time_ms >= 150),
    structural_advantage REAL GENERATED ALWAYS AS (
        structural_similarity -
        0.5 * surface_similarity -
        0.4 * relational_complexity -
        0.3 * working_memory_load +
        analogical_cue
    ) VIRTUAL
);

CREATE INDEX idx_analogy_condition ON analogical_reasoning_trials(condition);
CREATE INDEX idx_analogy_participant ON analogical_reasoning_trials(participant);
CREATE INDEX idx_analogy_source ON analogical_reasoning_trials(source_id);
CREATE INDEX idx_analogy_target ON analogical_reasoning_trials(target_id);

DROP VIEW IF EXISTS condition_summary;

CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(source_familiarity) AS mean_source_familiarity,
    AVG(target_novelty) AS mean_target_novelty,
    AVG(surface_similarity) AS mean_surface_similarity,
    AVG(structural_similarity) AS mean_structural_similarity,
    AVG(relational_complexity) AS mean_relational_complexity,
    AVG(working_memory_load) AS mean_working_memory_load,
    AVG(analogical_cue) AS analogical_cue_rate,
    AVG(mapping_accuracy) AS mapping_accuracy_rate,
    AVG(transfer_success) AS transfer_success_rate,
    AVG(inference_quality) AS mean_inference_quality,
    AVG(schema_abstraction) AS mean_schema_abstraction,
    AVG(confidence) AS mean_confidence,
    AVG(response_time_ms) AS mean_response_time_ms,
    AVG(structural_advantage) AS mean_structural_advantage
FROM analogical_reasoning_trials
GROUP BY condition;

DROP VIEW IF EXISTS misleading_surface_matches;

CREATE VIEW misleading_surface_matches AS
SELECT
    participant,
    condition,
    source_id,
    target_id,
    surface_similarity,
    structural_similarity,
    relational_complexity,
    mapping_accuracy,
    transfer_success,
    inference_quality,
    response_time_ms
FROM analogical_reasoning_trials
WHERE surface_similarity >= 7
  AND structural_similarity <= 5;

DROP VIEW IF EXISTS strong_transfer_cases;

CREATE VIEW strong_transfer_cases AS
SELECT
    participant,
    condition,
    source_id,
    target_id,
    structural_similarity,
    mapping_accuracy,
    transfer_success,
    inference_quality,
    schema_abstraction,
    confidence
FROM analogical_reasoning_trials
WHERE mapping_accuracy = 1
  AND transfer_success = 1
  AND inference_quality >= 80;
