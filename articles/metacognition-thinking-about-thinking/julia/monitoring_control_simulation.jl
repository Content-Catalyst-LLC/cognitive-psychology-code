#!/usr/bin/env julia

# Metacognition in cognitive psychology.
# Julia simulation of monitoring, calibration, and control.

using Random
using Statistics
using Printf
using DelimitedFiles

function logistic(x)
    return 1.0 / (1.0 + exp(-clamp(x, -40.0, 40.0)))
end

function simulate_trial(rng::AbstractRNG; condition="control")
    difficulty = condition == "high_difficulty" ? 7.5 + 2.0 * rand(rng) : 2.5 + 5.5 * rand(rng)
    evidence = condition == "feedback" || condition == "strategy_training" ? 5.5 + 3.5 * rand(rng) : 2.5 + 5.5 * rand(rng)
    prompt = condition == "metacognitive_prompt" || condition == "strategy_training" ? 1.0 : 0.0
    feedback = condition == "feedback" || condition == "strategy_training" ? 1.0 : 0.0
    skill = randn(rng)

    accuracy_prob = logistic(0.4 + 0.25 * evidence - 0.32 * difficulty + 0.25 * skill)
    accuracy = rand(rng) < accuracy_prob ? 1.0 : 0.0

    confidence = clamp(0.48 + 0.30 * accuracy - 0.035 * difficulty + 0.025 * evidence + 0.07 * skill + 0.03 * prompt + 0.12 * randn(rng), 0.0, 1.0)
    uncertainty = clamp(1.0 - confidence + 0.08 * randn(rng), 0.0, 1.0)
    calibration_error = abs(confidence - accuracy)

    shift_prob = logistic(-1.1 + 1.8 * uncertainty + 0.15 * difficulty - 1.1 * confidence + 0.35 * prompt + 0.25 * feedback + 0.20 * skill)
    strategy_shift = rand(rng) < shift_prob ? 1.0 : 0.0

    regulation = clamp(4.0 + 1.2 * skill + 1.1 * strategy_shift + 0.7 * feedback - 2.2 * calibration_error + 0.5 * prompt + randn(rng), 0.0, 10.0)

    return (
        difficulty = difficulty,
        evidence = evidence,
        accuracy = accuracy,
        confidence = confidence,
        uncertainty = uncertainty,
        calibration_error = calibration_error,
        strategy_shift = strategy_shift,
        regulation = regulation
    )
end

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_monitoring_control.csv")
    rng = MersenneTwister(seed)
    conditions = ["control", "feedback", "metacognitive_prompt", "high_difficulty", "strategy_training"]
    rows = Matrix{Any}(undef, n, 9)

    for i in 1:n
        condition = rand(rng, conditions)
        r = simulate_trial(rng; condition=condition)

        rows[i, :] = [
            i,
            condition,
            r.difficulty,
            r.evidence,
            r.accuracy,
            r.confidence,
            r.uncertainty,
            r.calibration_error,
            r.regulation
        ]
    end

    header = ["trial" "condition" "task_difficulty" "evidence_quality" "actual_accuracy" "confidence_rating" "uncertainty_rating" "calibration_error" "metacognitive_regulation_score"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    @printf("Monitoring-control simulation complete: %d trials\n", n)
    @printf("Mean calibration error: %.3f\n", mean(Float64.(rows[:, 8])))
    @printf("Mean regulation score: %.3f\n", mean(Float64.(rows[:, 9])))
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
