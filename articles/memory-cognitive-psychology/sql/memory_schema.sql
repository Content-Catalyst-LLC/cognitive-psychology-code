DROP TABLE IF EXISTS memory_trials;

CREATE TABLE memory_trials (
    participant TEXT NOT NULL,
    condition TEXT NOT NULL,
    domain TEXT NOT NULL,
    trial INTEGER NOT NULL CHECK (trial >= 1),
    item_id TEXT NOT NULL,
    memory_system TEXT NOT NULL,
    study_type TEXT NOT NULL,
    encoding_depth REAL NOT NULL CHECK (encoding_depth >= 0 AND encoding_depth <= 10),
    retrieval_practice INTEGER NOT NULL CHECK (retrieval_practice IN (0, 1)),
    spacing_interval REAL NOT NULL CHECK (spacing_interval >= 0),
    delay REAL NOT NULL CHECK (delay >= 0),
    retention_strength REAL NOT NULL CHECK (retention_strength >= 0),
    cue_quality REAL NOT NULL CHECK (cue_quality >= 0 AND cue_quality <= 10),
    interference REAL NOT NULL CHECK (interference >= 0 AND interference <= 10),
    consolidation_support REAL NOT NULL CHECK (consolidation_support >= 0 AND consolidation_support <= 10),
    source_context REAL NOT NULL CHECK (source_context >= 0 AND source_context <= 10),
    misinformation_exposure INTEGER NOT NULL CHECK (misinformation_exposure IN (0, 1)),
    old_item INTEGER NOT NULL CHECK (old_item IN (0, 1)),
    response_old INTEGER NOT NULL CHECK (response_old IN (0, 1)),
    source_correct INTEGER NOT NULL CHECK (source_correct IN (0, 1)),
    correct INTEGER NOT NULL CHECK (correct IN (0, 1)),
    recall_accuracy REAL NOT NULL CHECK (recall_accuracy >= 0 AND recall_accuracy <= 1),
    recognition_confidence REAL NOT NULL CHECK (recognition_confidence >= 0 AND recognition_confidence <= 1),
    retrieval_fluency REAL NOT NULL CHECK (retrieval_fluency >= 0 AND retrieval_fluency <= 10),
    response_time_ms REAL NOT NULL CHECK (response_time_ms >= 150),
    learning_transfer REAL NOT NULL CHECK (learning_transfer >= 0 AND learning_transfer <= 1),
    forgetting_rate REAL NOT NULL CHECK (forgetting_rate >= 0),
    false_alarm INTEGER GENERATED ALWAYS AS (CASE WHEN old_item = 0 AND response_old = 1 THEN 1 ELSE 0 END) VIRTUAL,
    hit INTEGER GENERATED ALWAYS AS (CASE WHEN old_item = 1 AND response_old = 1 THEN 1 ELSE 0 END) VIRTUAL
);

CREATE INDEX idx_memory_participant ON memory_trials(participant);
CREATE INDEX idx_memory_condition ON memory_trials(condition);
CREATE INDEX idx_memory_item ON memory_trials(item_id);
CREATE INDEX idx_memory_delay ON memory_trials(delay);

CREATE VIEW condition_summary AS
SELECT condition, COUNT(*) AS n_trials, COUNT(DISTINCT participant) AS n_participants,
       AVG(correct) AS correct_rate, AVG(recall_accuracy) AS mean_recall_accuracy,
       AVG(response_old) AS old_response_rate, AVG(source_correct) AS source_correct_rate,
       AVG(recognition_confidence) AS mean_confidence, AVG(retrieval_fluency) AS mean_fluency,
       AVG(response_time_ms) AS mean_response_time_ms, AVG(learning_transfer) AS mean_transfer,
       AVG(retention_strength) AS mean_retention_strength, AVG(forgetting_rate) AS mean_forgetting_rate
FROM memory_trials GROUP BY condition;

CREATE VIEW delay_summary AS
SELECT condition, delay, COUNT(*) AS n_trials, AVG(correct) AS correct_rate,
       AVG(recall_accuracy) AS mean_recall_accuracy, AVG(retention_strength) AS mean_retention_strength,
       AVG(response_time_ms) AS mean_response_time_ms
FROM memory_trials GROUP BY condition, delay;

CREATE VIEW misinformation_cases AS
SELECT participant, condition, domain, item_id, old_item, response_old, false_alarm,
       source_correct, recognition_confidence, source_context, interference, retrieval_fluency
FROM memory_trials WHERE misinformation_exposure = 1;

CREATE VIEW high_confidence_error_cases AS
SELECT participant, condition, domain, item_id, old_item, response_old, source_correct,
       correct, recognition_confidence, cue_quality, interference, misinformation_exposure
FROM memory_trials
WHERE recognition_confidence >= 0.75 AND correct = 0;
