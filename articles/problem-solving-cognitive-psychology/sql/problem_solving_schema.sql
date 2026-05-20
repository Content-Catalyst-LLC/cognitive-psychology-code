-- Problem solving in cognitive psychology.
-- Research schema and analytical views.

DROP TABLE IF EXISTS problem_solving_trials;

CREATE TABLE problem_solving_trials (
    participant TEXT NOT NULL,
    condition TEXT NOT NULL,
    problem_id TEXT NOT NULL,
    trial INTEGER NOT NULL,
    problem_difficulty REAL NOT NULL CHECK (problem_difficulty >= 0 AND problem_difficulty <= 10),
    representation_quality REAL NOT NULL CHECK (representation_quality >= 0 AND representation_quality <= 10),
    goal_clarity REAL NOT NULL CHECK (goal_clarity >= 0 AND goal_clarity <= 10),
    constraint_load REAL NOT NULL CHECK (constraint_load >= 0 AND constraint_load <= 10),
    wm_load REAL NOT NULL CHECK (wm_load >= 0 AND wm_load <= 10),
    strategy_type TEXT NOT NULL,
    metacognitive_monitoring REAL NOT NULL CHECK (metacognitive_monitoring >= 0 AND metacognitive_monitoring <= 10),
    strategy_switch_count INTEGER NOT NULL CHECK (strategy_switch_count >= 0),
    switched_strategy INTEGER NOT NULL CHECK (switched_strategy IN (0, 1)),
    insight_event INTEGER NOT NULL CHECK (insight_event IN (0, 1)),
    solution_accuracy INTEGER NOT NULL CHECK (solution_accuracy IN (0, 1)),
    solution_quality REAL NOT NULL CHECK (solution_quality >= 0 AND solution_quality <= 100),
    error_count INTEGER NOT NULL CHECK (error_count >= 0),
    confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 10),
    response_time_ms REAL NOT NULL CHECK (response_time_ms >= 150),
    problem_solving_support REAL GENERATED ALWAYS AS (
        representation_quality +
        goal_clarity +
        metacognitive_monitoring +
        1.5 * insight_event -
        0.5 * wm_load -
        0.4 * constraint_load -
        0.3 * problem_difficulty
    ) VIRTUAL
);

CREATE INDEX idx_ps_condition ON problem_solving_trials(condition);
CREATE INDEX idx_ps_participant ON problem_solving_trials(participant);
CREATE INDEX idx_ps_problem ON problem_solving_trials(problem_id);
CREATE INDEX idx_ps_strategy ON problem_solving_trials(strategy_type);

DROP VIEW IF EXISTS condition_summary;

CREATE VIEW condition_summary AS
SELECT
    condition,
    COUNT(*) AS n_trials,
    COUNT(DISTINCT participant) AS n_participants,
    AVG(problem_difficulty) AS mean_difficulty,
    AVG(representation_quality) AS mean_representation_quality,
    AVG(goal_clarity) AS mean_goal_clarity,
    AVG(constraint_load) AS mean_constraint_load,
    AVG(wm_load) AS mean_working_memory_load,
    AVG(metacognitive_monitoring) AS mean_metacognitive_monitoring,
    AVG(switched_strategy) AS switch_rate,
    AVG(strategy_switch_count) AS mean_switch_count,
    AVG(insight_event) AS insight_rate,
    AVG(solution_accuracy) AS accuracy_rate,
    AVG(solution_quality) AS mean_solution_quality,
    AVG(error_count) AS mean_error_count,
    AVG(confidence) AS mean_confidence,
    AVG(response_time_ms) AS mean_response_time_ms,
    AVG(problem_solving_support) AS mean_problem_solving_support
FROM problem_solving_trials
GROUP BY condition;

DROP VIEW IF EXISTS strategy_summary;

CREATE VIEW strategy_summary AS
SELECT
    strategy_type,
    COUNT(*) AS n_trials,
    AVG(problem_difficulty) AS mean_difficulty,
    AVG(solution_accuracy) AS accuracy_rate,
    AVG(solution_quality) AS mean_solution_quality,
    AVG(insight_event) AS insight_rate,
    AVG(error_count) AS mean_error_count,
    AVG(response_time_ms) AS mean_response_time_ms
FROM problem_solving_trials
GROUP BY strategy_type;

DROP VIEW IF EXISTS high_burden_trials;

CREATE VIEW high_burden_trials AS
SELECT
    participant,
    condition,
    problem_id,
    strategy_type,
    problem_difficulty,
    representation_quality,
    constraint_load,
    wm_load,
    metacognitive_monitoring,
    solution_accuracy,
    solution_quality,
    error_count,
    response_time_ms
FROM problem_solving_trials
WHERE wm_load >= 8
   OR constraint_load >= 8
   OR error_count >= 5
   OR response_time_ms >= 7000;
