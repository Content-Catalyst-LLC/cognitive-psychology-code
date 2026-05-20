-- Language processing in cognitive psychology.
-- Research schema and analytical views.

DROP TABLE IF EXISTS language_processing_trials;

CREATE TABLE language_processing_trials (
    participant TEXT NOT NULL,
    condition TEXT NOT NULL,
    trial INTEGER NOT NULL,
    item_id TEXT NOT NULL,
    modality TEXT NOT NULL,
    word_frequency REAL NOT NULL CHECK (word_frequency >= 0 AND word_frequency <= 10),
    lexical_ambiguity REAL NOT NULL CHECK (lexical_ambiguity >= 0 AND lexical_ambiguity <= 10),
    syntactic_complexity REAL NOT NULL CHECK (syntactic_complexity >= 0 AND syntactic_complexity <= 10),
    semantic_predictability REAL NOT NULL CHECK (semantic_predictability >= 0 AND semantic_predictability <= 10),
    context_support REAL NOT NULL CHECK (context_support >= 0 AND context_support <= 10),
    working_memory_load REAL NOT NULL CHECK (working_memory_load >= 0 AND working_memory_load <= 10),
    pragmatic_inference_demand REAL NOT NULL CHECK (pragmatic_inference_demand >= 0 AND pragmatic_inference_demand <= 10),
    discourse_coherence REAL NOT NULL CHECK (discourse_coherence >= 0 AND discourse_coherence <= 10),
    comprehension_accuracy INTEGER NOT NULL CHECK (comprehension_accuracy IN (0, 1)),
    lexical_decision_accuracy INTEGER NOT NULL CHECK (lexical_decision_accuracy IN (0, 1)),
    production_accuracy INTEGER NOT NULL CHECK (production_accuracy IN (0, 1)),
    reading_time_ms REAL NOT NULL CHECK (reading_time_ms >= 100),
    lexical_decision_rt_ms REAL NOT NULL CHECK (lexical_decision_rt_ms >= 100),
    production_latency_ms REAL NOT NULL CHECK (production_latency_ms >= 100),
    confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 10),
    processing_support REAL GENERATED ALWAYS AS (
        word_frequency +
        semantic_predictability +
        context_support +
        discourse_coherence -
        lexical_ambiguity -
        syntactic_complexity -
        working_memory_load -
        pragmatic_inference_demand
    ) VIRTUAL
);

CREATE INDEX idx_lp_condition ON language_processing_trials(condition);
CREATE INDEX idx_lp_participant ON language_processing_trials(participant);
CREATE INDEX idx_lp_item ON language_processing_trials(item_id);
CREATE INDEX idx_lp_modality ON language_processing_trials(modality);

DROP VIEW IF EXISTS condition_summary;

CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(word_frequency) AS mean_word_frequency,
    AVG(lexical_ambiguity) AS mean_lexical_ambiguity,
    AVG(syntactic_complexity) AS mean_syntactic_complexity,
    AVG(semantic_predictability) AS mean_semantic_predictability,
    AVG(context_support) AS mean_context_support,
    AVG(working_memory_load) AS mean_working_memory_load,
    AVG(pragmatic_inference_demand) AS mean_pragmatic_inference_demand,
    AVG(discourse_coherence) AS mean_discourse_coherence,
    AVG(comprehension_accuracy) AS comprehension_accuracy_rate,
    AVG(lexical_decision_accuracy) AS lexical_decision_accuracy_rate,
    AVG(production_accuracy) AS production_accuracy_rate,
    AVG(reading_time_ms) AS mean_reading_time_ms,
    AVG(lexical_decision_rt_ms) AS mean_lexical_decision_rt_ms,
    AVG(production_latency_ms) AS mean_production_latency_ms,
    AVG(confidence) AS mean_confidence,
    AVG(processing_support) AS mean_processing_support
FROM language_processing_trials
GROUP BY condition;

DROP VIEW IF EXISTS modality_summary;

CREATE VIEW modality_summary AS
SELECT
    modality,
    COUNT(*) AS n_trials,
    AVG(comprehension_accuracy) AS comprehension_accuracy_rate,
    AVG(lexical_decision_accuracy) AS lexical_decision_accuracy_rate,
    AVG(production_accuracy) AS production_accuracy_rate,
    AVG(reading_time_ms) AS mean_reading_time_ms,
    AVG(lexical_decision_rt_ms) AS mean_lexical_decision_rt_ms,
    AVG(production_latency_ms) AS mean_production_latency_ms,
    AVG(working_memory_load) AS mean_working_memory_load
FROM language_processing_trials
GROUP BY modality;

DROP VIEW IF EXISTS high_burden_language_items;

CREATE VIEW high_burden_language_items AS
SELECT
    participant,
    condition,
    item_id,
    modality,
    lexical_ambiguity,
    syntactic_complexity,
    working_memory_load,
    pragmatic_inference_demand,
    discourse_coherence,
    comprehension_accuracy,
    reading_time_ms,
    confidence
FROM language_processing_trials
WHERE syntactic_complexity >= 8
   OR working_memory_load >= 8
   OR pragmatic_inference_demand >= 8
   OR reading_time_ms >= 2400;
