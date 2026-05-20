#!/usr/bin/env julia

using Random
using Statistics
using Printf
using DelimitedFiles

function logistic(x)
    return 1.0 / (1.0 + exp(-x))
end

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_vigilance_ddm.csv")
    rng = MersenneTwister(seed)
    rows = Matrix{Any}(undef, n, 12)
    correct_sum = 0
    rt_sum = 0.0
    lapse_sum = 0.0

    for i in 1:n
        block = rand(rng, 1:8)
        cue_valid = rand(rng) < 0.45 ? 1 : 0
        target = rand(rng) < 0.50 ? 1 : 0
        salience = clamp(5.0 + 1.5 * randn(rng) + 0.8 * target, 0.0, 10.0)
        goal = clamp(5.5 + 1.0 * randn(rng) + 0.8 * cue_valid, 0.0, 10.0)
        load = clamp(3.0 + 2.0 * rand(rng) + 0.35 * block, 0.0, 10.0)
        vigilance = clamp(8.0 - 0.42 * block - 0.22 * load + randn(rng), 0.0, 10.0)
        lapse = logistic(-2.6 + 0.34 * block + 0.22 * load - 0.30 * vigilance)
        drift = 0.12 + 0.06 * salience + 0.05 * goal - 0.05 * load - 0.30 * lapse
        threshold = 1.0 + 0.10 * load
        ndt = 0.28 + 0.025 * block - 0.02 * cue_valid
        rt = ndt + threshold / max(0.05, drift) + 0.12 * randn(rng)
        p_correct = logistic(2.0 * drift - 0.18 * load - 0.35 * lapse)
        correct = rand(rng) < p_correct ? 1 : 0

        correct_sum += correct
        rt_sum += rt
        lapse_sum += lapse

        rows[i, :] = [i, block, cue_valid, target, salience, goal, load, vigilance, lapse, drift, rt, correct]
    end

    header = ["trial" "block" "cue_valid" "target_present" "salience" "goal_relevance" "load" "vigilance_state" "lapse_probability" "drift_rate" "rt_seconds" "correct"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    @printf("Vigilance/DDM simulation complete: %d trials\n", n)
    @printf("Correct rate: %.3f\n", correct_sum / n)
    @printf("Mean RT seconds: %.3f\n", rt_sum / n)
    @printf("Mean lapse probability: %.3f\n", lapse_sum / n)
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
