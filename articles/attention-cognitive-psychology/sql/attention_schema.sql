DROP TABLE IF EXISTS attention_trials;

CREATE TABLE attention_trials (
    participant TEXT NOT NULL,
    condition TEXT NOT NULL,
    domain TEXT NOT NULL,
    trial INTEGER NOT NULL CHECK (trial >= 1),
    block INTEGER NOT NULL CHECK (block >= 1),
    stimulus_id TEXT NOT NULL,
    cue_validity TEXT NOT NULL,
    task_type TEXT NOT NULL,
    target_present INTEGER NOT NULL CHECK (target_present IN (0, 1)),
    response_yes INTEGER NOT NULL CHECK (response_yes IN (0, 1)),
    correct INTEGER NOT NULL CHECK (correct IN (0, 1)),
    rt REAL NOT NULL CHECK (rt >= 150),
    salience REAL NOT NULL CHECK (salience >= 0 AND salience <= 10),
    goal_relevance REAL NOT NULL CHECK (goal_relevance >= 0 AND goal_relevance <= 10),
    distractor_load REAL NOT NULL CHECK (distractor_load >= 0 AND distractor_load <= 10),
    perceptual_load REAL NOT NULL CHECK (perceptual_load >= 0 AND perceptual_load <= 10),
    executive_load REAL NOT NULL CHECK (executive_load >= 0 AND executive_load <= 10),
    task_switch INTEGER NOT NULL CHECK (task_switch IN (0, 1)),
    conflict REAL NOT NULL CHECK (conflict >= 0 AND conflict <= 10),
    vigilance_state REAL NOT NULL CHECK (vigilance_state >= 0 AND vigilance_state <= 10),
    lapse_probability REAL NOT NULL CHECK (lapse_probability >= 0 AND lapse_probability <= 1),
    confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
    interface_salience REAL NOT NULL CHECK (interface_salience >= 0 AND interface_salience <= 10),
    notification_load REAL NOT NULL CHECK (notification_load >= 0 AND notification_load <= 10),
    divided_attention_cost REAL NOT NULL CHECK (divided_attention_cost >= 0 AND divided_attention_cost <= 1),
    hit INTEGER GENERATED ALWAYS AS (CASE WHEN target_present = 1 AND response_yes = 1 THEN 1 ELSE 0 END) VIRTUAL,
    false_alarm INTEGER GENERATED ALWAYS AS (CASE WHEN target_present = 0 AND response_yes = 1 THEN 1 ELSE 0 END) VIRTUAL
);

CREATE INDEX idx_attention_participant ON attention_trials(participant);
CREATE INDEX idx_attention_condition ON attention_trials(condition);
CREATE INDEX idx_attention_task_type ON attention_trials(task_type);
CREATE INDEX idx_attention_cue_validity ON attention_trials(cue_validity);
CREATE INDEX idx_attention_block ON attention_trials(block);

DROP VIEW IF EXISTS condition_summary;
CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(correct) AS correct_rate,
    AVG(response_yes) AS yes_rate,
    AVG(rt) AS mean_rt,
    AVG(confidence) AS mean_confidence,
    AVG(lapse_probability) AS mean_lapse_probability,
    AVG(vigilance_state) AS mean_vigilance_state,
    AVG(distractor_load) AS mean_distractor_load,
    AVG(executive_load) AS mean_executive_load,
    AVG(divided_attention_cost) AS mean_divided_attention_cost
FROM attention_trials
GROUP BY condition;

DROP VIEW IF EXISTS cueing_summary;
CREATE VIEW cueing_summary AS
SELECT
    condition,
    cue_validity,
    COUNT(*) AS n_trials,
    AVG(correct) AS correct_rate,
    AVG(rt) AS mean_rt,
    AVG(confidence) AS mean_confidence
FROM attention_trials
GROUP BY condition, cue_validity;

DROP VIEW IF EXISTS vigilance_summary;
CREATE VIEW vigilance_summary AS
SELECT
    condition,
    block,
    COUNT(*) AS n_trials,
    AVG(correct) AS correct_rate,
    AVG(response_yes) AS yes_rate,
    AVG(rt) AS mean_rt,
    AVG(vigilance_state) AS mean_vigilance_state,
    AVG(lapse_probability) AS mean_lapse_probability
FROM attention_trials
GROUP BY condition, block;

DROP VIEW IF EXISTS high_confidence_errors;
CREATE VIEW high_confidence_errors AS
SELECT
    participant, condition, domain, trial, block, task_type, target_present,
    response_yes, correct, rt, confidence, salience, goal_relevance,
    distractor_load, executive_load, lapse_probability
FROM attention_trials
WHERE correct = 0 AND confidence >= 0.75;

DROP VIEW IF EXISTS overload_cases;
CREATE VIEW overload_cases AS
SELECT
    participant, condition, domain, trial, block, task_type, correct, rt,
    distractor_load, perceptual_load, executive_load, notification_load,
    divided_attention_cost, lapse_probability
FROM attention_trials
WHERE distractor_load >= 7 OR executive_load >= 7 OR notification_load >= 7;
