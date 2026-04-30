-- Root schema for cognitive psychology experiment metadata.

CREATE TABLE IF NOT EXISTS participants (
    participant_id TEXT PRIMARY KEY,
    age_years INTEGER,
    language_background TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS tasks (
    task_id TEXT PRIMARY KEY,
    task_name TEXT NOT NULL,
    article_slug TEXT NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS trials (
    trial_id INTEGER PRIMARY KEY,
    participant_id TEXT NOT NULL,
    task_id TEXT NOT NULL,
    trial_index INTEGER NOT NULL,
    stimulus_condition TEXT,
    response TEXT,
    correct INTEGER,
    reaction_time_ms REAL,
    cognitive_load_level REAL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
