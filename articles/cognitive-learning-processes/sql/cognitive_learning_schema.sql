-- Cognitive learning processes.
-- Research schema and analytical views.

DROP TABLE IF EXISTS cognitive_learning_trials;

CREATE TABLE cognitive_learning_trials (
    participant TEXT NOT NULL,
    condition TEXT NOT NULL,
    domain TEXT NOT NULL,
    session INTEGER NOT NULL CHECK (session >= 1),
    item_id TEXT NOT NULL,
    prior_knowledge REAL NOT NULL CHECK (prior_knowledge >= 0 AND prior_knowledge <= 10),
    attention_score REAL NOT NULL CHECK (attention_score >= 0 AND attention_score <= 10),
    encoding_quality REAL NOT NULL CHECK (encoding_quality >= 0 AND encoding_quality <= 10),
    working_memory_load REAL NOT NULL CHECK (working_memory_load >= 0 AND working_memory_load <= 10),
    schema_strength REAL NOT NULL CHECK (schema_strength >= 0 AND schema_strength <= 10),
    retrieval_practice INTEGER NOT NULL CHECK (retrieval_practice IN (0, 1)),
    feedback_quality REAL NOT NULL CHECK (feedback_quality >= 0 AND feedback_quality <= 10),
    cognitive_load REAL NOT NULL CHECK (cognitive_load >= 0 AND cognitive_load <= 10),
    comprehension_score REAL NOT NULL CHECK (comprehension_score >= 0 AND comprehension_score <= 100),
    accuracy REAL NOT NULL CHECK (accuracy >= 0 AND accuracy <= 1),
    transfer_score REAL NOT NULL CHECK (transfer_score >= 0 AND transfer_score <= 100),
    retention_score REAL NOT NULL CHECK (retention_score >= 0 AND retention_score <= 100),
    response_time_ms REAL NOT NULL CHECK (response_time_ms >= 150),
    learning_gain REAL NOT NULL CHECK (learning_gain >= -100 AND learning_gain <= 100),
    adaptive_application REAL NOT NULL CHECK (adaptive_application >= 0 AND adaptive_application <= 10),
    learning_support REAL GENERATED ALWAYS AS (
        prior_knowledge + attention_score + encoding_quality + schema_strength +
        retrieval_practice + feedback_quality + adaptive_application -
        cognitive_load - working_memory_load
    ) VIRTUAL
);

CREATE INDEX idx_cl_participant ON cognitive_learning_trials(participant);
CREATE INDEX idx_cl_condition ON cognitive_learning_trials(condition);
CREATE INDEX idx_cl_domain ON cognitive_learning_trials(domain);
CREATE INDEX idx_cl_session ON cognitive_learning_trials(session);

DROP VIEW IF EXISTS condition_summary;

CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(prior_knowledge) AS mean_prior_knowledge,
    AVG(attention_score) AS mean_attention,
    AVG(encoding_quality) AS mean_encoding,
    AVG(schema_strength) AS mean_schema_strength,
    AVG(retrieval_practice) AS retrieval_rate,
    AVG(feedback_quality) AS mean_feedback,
    AVG(cognitive_load) AS mean_cognitive_load,
    AVG(comprehension_score) AS mean_comprehension,
    AVG(accuracy) AS mean_accuracy,
    AVG(transfer_score) AS mean_transfer,
    AVG(retention_score) AS mean_retention,
    AVG(response_time_ms) AS mean_response_time_ms,
    AVG(learning_gain) AS mean_learning_gain,
    AVG(adaptive_application) AS mean_adaptive_application,
    AVG(learning_support) AS mean_learning_support
FROM cognitive_learning_trials
GROUP BY condition;

DROP VIEW IF EXISTS learning_curve;

CREATE VIEW learning_curve AS
SELECT
    condition,
    session,
    AVG(accuracy) AS mean_accuracy,
    AVG(comprehension_score) AS mean_comprehension,
    AVG(transfer_score) AS mean_transfer,
    AVG(retention_score) AS mean_retention,
    AVG(cognitive_load) AS mean_cognitive_load
FROM cognitive_learning_trials
GROUP BY condition, session;

DROP VIEW IF EXISTS high_load_cases;

CREATE VIEW high_load_cases AS
SELECT
    participant,
    condition,
    domain,
    session,
    item_id,
    working_memory_load,
    cognitive_load,
    comprehension_score,
    accuracy,
    transfer_score,
    retention_score
FROM cognitive_learning_trials
WHERE cognitive_load >= 8 OR working_memory_load >= 8;
