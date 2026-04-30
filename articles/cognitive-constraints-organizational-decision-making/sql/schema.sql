-- Article-level synthetic trial schema.

CREATE TABLE IF NOT EXISTS article_trials (
    trial_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    trial_index INTEGER NOT NULL,
    stimulus_condition TEXT,
    response TEXT,
    correct INTEGER,
    reaction_time_ms REAL,
    working_memory_load REAL,
    attentional_demand REAL
);
