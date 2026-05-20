DROP TABLE IF EXISTS perception_trials;

CREATE TABLE perception_trials (
    participant TEXT NOT NULL,
    condition TEXT NOT NULL,
    domain TEXT NOT NULL,
    trial INTEGER NOT NULL CHECK (trial >= 1),
    stimulus_id TEXT NOT NULL,
    modality TEXT NOT NULL,
    stimulus_level REAL NOT NULL,
    signal_present INTEGER NOT NULL CHECK (signal_present IN (0, 1)),
    response_yes INTEGER NOT NULL CHECK (response_yes IN (0, 1)),
    correct INTEGER NOT NULL CHECK (correct IN (0, 1)),
    sensory_evidence REAL NOT NULL,
    prior_expectation REAL NOT NULL CHECK (prior_expectation >= 0 AND prior_expectation <= 10),
    cue_quality REAL NOT NULL CHECK (cue_quality >= 0 AND cue_quality <= 10),
    attention_gain REAL NOT NULL CHECK (attention_gain >= 0 AND attention_gain <= 10),
    context_strength REAL NOT NULL CHECK (context_strength >= 0 AND context_strength <= 10),
    noise_level REAL NOT NULL CHECK (noise_level >= 0 AND noise_level <= 10),
    prediction_error REAL NOT NULL CHECK (prediction_error >= 0),
    perceptual_threshold REAL NOT NULL,
    confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
    response_time_ms REAL NOT NULL CHECK (response_time_ms >= 150),
    multisensory_congruence REAL NOT NULL CHECK (multisensory_congruence >= 0 AND multisensory_congruence <= 1),
    visual_search_set_size INTEGER NOT NULL CHECK (visual_search_set_size >= 1),
    distractor_similarity REAL NOT NULL CHECK (distractor_similarity >= 0 AND distractor_similarity <= 10),
    perceptual_learning_block INTEGER NOT NULL CHECK (perceptual_learning_block >= 1),
    interface_salience REAL NOT NULL CHECK (interface_salience >= 0 AND interface_salience <= 10),
    hit INTEGER GENERATED ALWAYS AS (CASE WHEN signal_present = 1 AND response_yes = 1 THEN 1 ELSE 0 END) VIRTUAL,
    false_alarm INTEGER GENERATED ALWAYS AS (CASE WHEN signal_present = 0 AND response_yes = 1 THEN 1 ELSE 0 END) VIRTUAL
);

CREATE INDEX idx_perception_participant ON perception_trials(participant);
CREATE INDEX idx_perception_condition ON perception_trials(condition);
CREATE INDEX idx_perception_stimulus ON perception_trials(stimulus_id);
CREATE INDEX idx_perception_modality ON perception_trials(modality);
CREATE INDEX idx_perception_signal ON perception_trials(signal_present);

DROP VIEW IF EXISTS condition_summary;
CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(correct) AS correct_rate,
    AVG(response_yes) AS yes_rate,
    AVG(confidence) AS mean_confidence,
    AVG(response_time_ms) AS mean_response_time_ms,
    AVG(sensory_evidence) AS mean_sensory_evidence,
    AVG(prediction_error) AS mean_prediction_error,
    AVG(perceptual_threshold) AS mean_threshold,
    AVG(noise_level) AS mean_noise,
    AVG(attention_gain) AS mean_attention_gain,
    AVG(context_strength) AS mean_context_strength
FROM perception_trials
GROUP BY condition;

DROP VIEW IF EXISTS high_confidence_error_cases;
CREATE VIEW high_confidence_error_cases AS
SELECT
    participant, condition, domain, stimulus_id, modality, stimulus_level,
    signal_present, response_yes, correct, confidence, sensory_evidence,
    prior_expectation, cue_quality, attention_gain, context_strength, noise_level,
    prediction_error, response_time_ms
FROM perception_trials
WHERE correct = 0 AND confidence >= 0.75;

DROP VIEW IF EXISTS difficult_search_cases;
CREATE VIEW difficult_search_cases AS
SELECT
    participant, condition, stimulus_id, visual_search_set_size, distractor_similarity,
    correct, confidence, response_time_ms, interface_salience
FROM perception_trials
WHERE visual_search_set_size >= 16 OR distractor_similarity >= 7;

DROP VIEW IF EXISTS prediction_error_cases;
CREATE VIEW prediction_error_cases AS
SELECT
    participant, condition, modality, stimulus_id, prediction_error, prior_expectation,
    context_strength, noise_level, correct, confidence, response_time_ms
FROM perception_trials
WHERE prediction_error >= 3;
