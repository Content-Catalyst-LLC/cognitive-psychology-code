#!/usr/bin/env julia

# Cognitive load and information processing.
# Julia simulation of nonlinear load-capacity performance.

using Random
using Statistics
using Printf
using DelimitedFiles

function logistic(x)
    return 1.0 / (1.0 + exp(-x))
end

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_load_capacity.csv")
    rng = MersenneTwister(seed)
    conditions = ["worked_example", "problem_solving", "split_attention", "integrated_design", "redundant", "coherence", "signaling", "ai_assisted", "control"]
    rows = Matrix{Any}(undef, n, 11)

    for i in 1:n
        condition = rand(rng, conditions)
        design_bonus = condition in ["worked_example", "integrated_design", "coherence", "signaling"] ? 1.4 : 0.0
        extraneous_penalty = condition in ["problem_solving", "split_attention", "redundant"] ? 1.8 : 0.0

        prior = clamp(5.0 + 2.0 * randn(rng), 0.0, 10.0)
        capacity = clamp(6.0 + 0.2 * prior + 0.8 * randn(rng), 0.0, 10.0)
        intrinsic = clamp(5.5 + 1.4 * randn(rng), 0.0, 10.0)
        extraneous = clamp(3.4 + extraneous_penalty - design_bonus + 1.2 * randn(rng), 0.0, 10.0)
        germane = clamp(4.8 + design_bonus - 0.25 * extraneous + 1.0 * randn(rng), 0.0, 10.0)
        total_load = intrinsic + extraneous + 0.55 * germane
        margin = capacity + 0.45 * prior - total_load
        p_success = logistic(-0.6 + 0.55 * margin + 0.24 * germane - 0.22 * extraneous)
        effort = clamp(4.0 + 0.35 * intrinsic + 0.50 * extraneous + 0.18 * germane - 0.22 * prior + randn(rng), 0.0, 10.0)
        efficiency = (p_success - effort / 10.0) / sqrt(2)

        rows[i, :] = [i, condition, prior, capacity, intrinsic, extraneous, germane, total_load, margin, p_success, efficiency]
    end

    header = ["trial" "condition" "prior_knowledge" "working_memory_capacity" "intrinsic_load" "extraneous_load" "germane_load" "total_load" "overload_margin" "success_probability" "mental_efficiency"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    @printf("Load-capacity simulation complete: %d trials\n", n)
    @printf("Mean overload margin: %.3f\n", mean(Float64.(rows[:, 9])))
    @printf("Mean success probability: %.3f\n", mean(Float64.(rows[:, 10])))
    @printf("Mean mental efficiency: %.3f\n", mean(Float64.(rows[:, 11])))
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
