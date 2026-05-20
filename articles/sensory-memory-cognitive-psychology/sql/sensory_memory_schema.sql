-- Sensory memory in cognitive psychology.
-- Research schema and analytical views.

DROP TABLE IF EXISTS sensory_memory_trials;

CREATE TABLE sensory_memory_trials (
    participant TEXT NOT NULL,
    modality TEXT NOT NULL,
    condition TEXT NOT NULL,
    trial INTEGER NOT NULL CHECK (trial >= 1),
    stimulus_id TEXT NOT NULL,
    cue_delay_ms REAL NOT NULL CHECK (cue_delay_ms >= 0),
    stimulus_duration_ms REAL NOT NULL CHECK (stimulus_duration_ms > 0),
    array_size INTEGER NOT NULL CHECK (array_size >= 1),
    cue_validity REAL NOT NULL CHECK (cue_validity >= 0 AND cue_validity <= 1),
    mask_present INTEGER NOT NULL CHECK (mask_present IN (0, 1)),
    trace_strength REAL NOT NULL CHECK (trace_strength >= 0 AND trace_strength <= 1),
    salience REAL NOT NULL CHECK (salience >= 0 AND salience <= 10),
    attentional_priority REAL NOT NULL CHECK (attentional_priority >= 0 AND attentional_priority <= 10),
    report_score REAL NOT NULL CHECK (report_score >= 0),
    correct INTEGER NOT NULL CHECK (correct IN (0, 1)),
    selection_probability REAL NOT NULL CHECK (selection_probability >= 0 AND selection_probability <= 1),
    wm_transfer INTEGER NOT NULL CHECK (wm_transfer IN (0, 1)),
    rt_ms REAL NOT NULL CHECK (rt_ms >= 100),
    confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 10),
    perceptual_continuity REAL NOT NULL CHECK (perceptual_continuity >= 0 AND perceptual_continuity <= 10),
    partial_report_indicator INTEGER GENERATED ALWAYS AS (
        CASE WHEN condition IN ('partial_report','valid_cue','invalid_cue','neutral_cue') THEN 1 ELSE 0 END
    ) VIRTUAL
);

CREATE INDEX idx_sm_participant ON sensory_memory_trials(participant);
CREATE INDEX idx_sm_modality ON sensory_memory_trials(modality);
CREATE INDEX idx_sm_condition ON sensory_memory_trials(condition);
CREATE INDEX idx_sm_delay ON sensory_memory_trials(cue_delay_ms);
CREATE INDEX idx_sm_stimulus ON sensory_memory_trials(stimulus_id);

DROP VIEW IF EXISTS modality_delay_summary;

CREATE VIEW modality_delay_summary AS
SELECT
    modality,
    cue_delay_ms,
    COUNT(*) AS n_trials,
    AVG(correct) AS accuracy,
    AVG(report_score) AS mean_report,
    AVG(trace_strength) AS mean_trace,
    AVG(selection_probability) AS mean_selection_probability,
    AVG(wm_transfer) AS wm_transfer_rate,
    AVG(rt_ms) AS mean_rt_ms,
    AVG(confidence) AS mean_confidence
FROM sensory_memory_trials
GROUP BY modality, cue_delay_ms;

DROP VIEW IF EXISTS condition_summary;

CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(correct) AS accuracy,
    AVG(report_score) AS mean_report,
    AVG(trace_strength) AS mean_trace,
    AVG(selection_probability) AS mean_selection_probability,
    AVG(wm_transfer) AS wm_transfer_rate,
    AVG(rt_ms) AS mean_rt_ms,
    AVG(confidence) AS mean_confidence,
    AVG(perceptual_continuity) AS mean_perceptual_continuity
FROM sensory_memory_trials
GROUP BY condition;

DROP VIEW IF EXISTS partial_report_advantage_summary;

CREATE VIEW partial_report_advantage_summary AS
SELECT
    modality,
    AVG(CASE WHEN partial_report_indicator = 1 THEN report_score END) -
    AVG(CASE WHEN condition = 'whole_report' THEN report_score END) AS partial_report_advantage
FROM sensory_memory_trials
GROUP BY modality;

DROP VIEW IF EXISTS high_trace_low_report_cases;

CREATE VIEW high_trace_low_report_cases AS
SELECT
    participant,
    modality,
    condition,
    stimulus_id,
    cue_delay_ms,
    trace_strength,
    attentional_priority,
    report_score,
    correct,
    selection_probability,
    wm_transfer
FROM sensory_memory_trials
WHERE trace_strength >= 0.70
  AND correct = 0;
