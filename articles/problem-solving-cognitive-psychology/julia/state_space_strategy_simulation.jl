#!/usr/bin/env julia

# Problem solving in cognitive psychology.
# Julia simulation of state-space search, means-end analysis,
# representation quality, and strategy selection.

using Random
using Statistics
using Printf
using DelimitedFiles

function logistic(x)
    return 1.0 / (1.0 + exp(-clamp(x, -40.0, 40.0)))
end

function simulate_trial(rng::AbstractRNG; condition="control")
    difficulty = 2.0 + 7.0 * rand(rng)

    representation = condition == "representation_support" ? 7.0 + 2.5 * rand(rng) : 3.0 + 5.5 * rand(rng)
    metacognition = condition == "metacognitive_prompt" ? 7.0 + 2.5 * rand(rng) : 3.0 + 5.5 * rand(rng)
    wm_load = condition == "high_load" ? 7.2 + 2.0 * rand(rng) : 2.5 + 5.5 * rand(rng)
    constraint = condition == "dynamic_uncertainty" ? 7.0 + 2.5 * rand(rng) : 3.0 + 5.5 * rand(rng)

    strategy_bonus = condition == "analogical_support" ? 0.55 : 0.0

    insight_prob = logistic(
        -2.1 +
        0.45 * representation +
        0.20 * metacognition -
        0.22 * wm_load -
        0.18 * constraint +
        strategy_bonus
    )

    insight = rand(rng) < insight_prob ? 1 : 0

    accuracy_prob = logistic(
        -2.0 +
        0.40 * representation +
        0.25 * metacognition +
        0.55 * insight -
        0.30 * difficulty -
        0.22 * wm_load -
        0.16 * constraint
    )

    accuracy = rand(rng) < accuracy_prob ? 1 : 0

    quality = clamp(35.0 + 4.8 * representation + 2.8 * metacognition + 8.0 * accuracy + 4.0 * insight - 2.2 * difficulty - 1.5 * wm_load + 7.0 * randn(rng), 0.0, 100.0)

    return (
        difficulty = difficulty,
        representation = representation,
        metacognition = metacognition,
        wm_load = wm_load,
        constraint = constraint,
        insight = insight,
        accuracy = accuracy,
        quality = quality
    )
end

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_state_space_strategy.csv")
    rng = MersenneTwister(seed)
    conditions = ["control", "high_load", "representation_support", "analogical_support", "metacognitive_prompt", "dynamic_uncertainty"]
    rows = Matrix{Any}(undef, n, 9)

    for i in 1:n
        condition = rand(rng, conditions)
        r = simulate_trial(rng; condition=condition)

        rows[i, :] = [
            i,
            condition,
            r.difficulty,
            r.representation,
            r.metacognition,
            r.wm_load,
            r.constraint,
            r.accuracy,
            r.quality
        ]
    end

    header = ["trial" "condition" "problem_difficulty" "representation_quality" "metacognitive_monitoring" "wm_load" "constraint_load" "solution_accuracy" "solution_quality"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    accuracy = Float64.(rows[:, 8])
    quality = Float64.(rows[:, 9])
    representation = Float64.(rows[:, 4])

    @printf("Simulation complete: %d trials\n", n)
    @printf("Accuracy rate: %.3f\n", mean(accuracy))
    @printf("Mean solution quality: %.3f\n", mean(quality))
    @printf("Mean representation quality: %.3f\n", mean(representation))
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
