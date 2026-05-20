DROP TABLE IF EXISTS skill_acquisition_trials;

CREATE TABLE skill_acquisition_trials (
    participant TEXT NOT NULL,
    expertise_level TEXT NOT NULL,
    condition TEXT NOT NULL,
    domain TEXT NOT NULL,
    session INTEGER NOT NULL CHECK (session >= 1),
    task_id TEXT NOT NULL,
    practice_hours REAL NOT NULL CHECK (practice_hours >= 0),
    deliberate_practice_quality REAL NOT NULL CHECK (deliberate_practice_quality BETWEEN 0 AND 10),
    feedback_quality REAL NOT NULL CHECK (feedback_quality BETWEEN 0 AND 10),
    task_difficulty REAL NOT NULL CHECK (task_difficulty BETWEEN 0 AND 10),
    cognitive_load REAL NOT NULL CHECK (cognitive_load BETWEEN 0 AND 10),
    working_memory_demand REAL NOT NULL CHECK (working_memory_demand BETWEEN 0 AND 10),
    chunking_score REAL NOT NULL CHECK (chunking_score BETWEEN 0 AND 10),
    pattern_recognition_score REAL NOT NULL CHECK (pattern_recognition_score BETWEEN 0 AND 10),
    strategy_quality REAL NOT NULL CHECK (strategy_quality BETWEEN 0 AND 10),
    transfer_score REAL NOT NULL CHECK (transfer_score BETWEEN 0 AND 100),
    adaptive_flexibility REAL NOT NULL CHECK (adaptive_flexibility BETWEEN 0 AND 10),
    accuracy REAL NOT NULL CHECK (accuracy BETWEEN 0 AND 1),
    error_rate REAL NOT NULL CHECK (error_rate BETWEEN 0 AND 1),
    response_time_ms REAL NOT NULL CHECK (response_time_ms >= 150),
    automaticity_score REAL NOT NULL CHECK (automaticity_score BETWEEN 0 AND 10),
    retention_score REAL NOT NULL CHECK (retention_score BETWEEN 0 AND 100)
);

CREATE INDEX idx_sa_participant ON skill_acquisition_trials(participant);
CREATE INDEX idx_sa_expertise ON skill_acquisition_trials(expertise_level);
CREATE INDEX idx_sa_condition ON skill_acquisition_trials(condition);
CREATE INDEX idx_sa_session ON skill_acquisition_trials(session);

CREATE VIEW condition_summary AS
SELECT condition, COUNT(*) AS n_trials, COUNT(DISTINCT participant) AS n_participants,
       AVG(accuracy) AS mean_accuracy, AVG(error_rate) AS mean_error_rate,
       AVG(response_time_ms) AS mean_response_time_ms, AVG(transfer_score) AS mean_transfer_score,
       AVG(automaticity_score) AS mean_automaticity, AVG(retention_score) AS mean_retention
FROM skill_acquisition_trials GROUP BY condition;

CREATE VIEW expertise_summary AS
SELECT expertise_level, COUNT(*) AS n_trials, COUNT(DISTINCT participant) AS n_participants,
       AVG(accuracy) AS mean_accuracy, AVG(error_rate) AS mean_error_rate,
       AVG(response_time_ms) AS mean_response_time_ms, AVG(chunking_score) AS mean_chunking,
       AVG(pattern_recognition_score) AS mean_pattern_recognition,
       AVG(automaticity_score) AS mean_automaticity, AVG(transfer_score) AS mean_transfer_score
FROM skill_acquisition_trials GROUP BY expertise_level;

CREATE VIEW learning_curve AS
SELECT expertise_level, session, AVG(accuracy) AS mean_accuracy, AVG(error_rate) AS mean_error_rate,
       AVG(response_time_ms) AS mean_response_time_ms, AVG(automaticity_score) AS mean_automaticity
FROM skill_acquisition_trials GROUP BY expertise_level, session;
