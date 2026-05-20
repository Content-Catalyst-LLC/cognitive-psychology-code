#!/usr/bin/env julia

# Working memory in cognitive psychology.
# Julia simulation of capacity limits and gated updating.

using Random
using Statistics
using Printf
using DelimitedFiles

function logistic(x)
    return 1.0 / (1.0 + exp(-x))
end

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_capacity_gating.csv")
    rng = MersenneTwister(seed)
    rows = Matrix{Any}(undef, n, 11)

    correct_sum = 0
    overload_sum = 0.0

    for i in 1:n
        capacity = clamp(4.2 + 0.8 * randn(rng), 1.5, 8.0)
        load = rand(rng, 1:10)
        interference = 10.0 * rand(rng)
        attentional_control = clamp(6.0 + 1.0 * randn(rng), 0.0, 10.0)
        update_gate = clamp(0.55 + 0.08 * attentional_control - 0.06 * interference + 0.10 * randn(rng), 0.0, 1.0)
        stability_gate = 1.0 - update_gate
        overload = max(0.0, load - capacity)
        overload_probability = logistic(-1.8 + 0.75 * overload + 0.15 * interference - 0.12 * attentional_control)
        accuracy = logistic(2.0 + 0.55 * capacity - 0.55 * load - 0.22 * interference + 0.18 * attentional_control + 0.35 * update_gate)
        correct = rand(rng) < accuracy ? 1 : 0

        correct_sum += correct
        overload_sum += overload_probability

        rows[i, :] = [i, capacity, load, interference, attentional_control, update_gate, stability_gate, overload, overload_probability, accuracy, correct]
    end

    header = ["trial" "capacity" "load" "interference" "attentional_control" "update_gate" "stability_gate" "overload" "overload_probability" "accuracy" "correct"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    @printf("Capacity and gating simulation complete: %d trials\n", n)
    @printf("Correct rate: %.3f\n", correct_sum / n)
    @printf("Mean overload probability: %.3f\n", overload_sum / n)
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
