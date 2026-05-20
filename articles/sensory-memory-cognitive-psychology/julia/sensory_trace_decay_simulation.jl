#!/usr/bin/env julia

# Sensory memory in cognitive psychology.
# Julia simulation of modality-specific trace decay and report probability.

using Random
using Statistics
using Printf
using DelimitedFiles

function logistic(x)
    return 1.0 / (1.0 + exp(-x))
end

function trace_strength(delay_ms, s0, lambda)
    return s0 * exp(-lambda * delay_ms)
end

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_sensory_trace_decay.csv")
    rng = MersenneTwister(seed)
    modalities = ["visual", "auditory", "tactile", "multimodal"]
    rows = Matrix{Any}(undef, n, 9)

    for i in 1:n
        modality = rand(rng, modalities)
        if modality == "visual"
            s0, lambda, delay = 0.95, 0.0048, rand(rng, [0, 50, 100, 150, 250, 400, 700])
        elseif modality == "auditory"
            s0, lambda, delay = 0.92, 0.00055, rand(rng, [0, 250, 500, 1000, 2000, 3500, 5000])
        elseif modality == "tactile"
            s0, lambda, delay = 0.82, 0.00125, rand(rng, [0, 150, 300, 600, 1000, 1600, 2400])
        else
            s0, lambda, delay = 0.90, 0.00110, rand(rng, [0, 100, 250, 500, 1000, 2000, 3500])
        end

        salience = 10.0 * rand(rng)
        priority = 10.0 * rand(rng)
        mask = rand(rng) < 0.25 ? 1.0 : 0.0
        trace = trace_strength(delay, s0 + 0.03 * randn(rng), lambda * (1.0 + 0.1 * randn(rng)))
        trace = clamp(trace * (mask > 0 ? 0.58 : 1.0), 0.0, 1.0)

        p_correct = logistic(-1.2 + 3.1 * trace + 0.18 * salience + 0.28 * priority - 0.45 * mask)
        correct = rand(rng) < p_correct ? 1.0 : 0.0
        rt = clamp(exp(log(900.0) + 0.00012 * delay - 0.12 * correct + 0.06 * mask + 0.12 * randn(rng)), 100.0, 20000.0)

        rows[i, :] = [i, modality, delay, salience, priority, mask, trace, p_correct, rt]
    end

    header = ["trial" "modality" "cue_delay_ms" "salience" "attentional_priority" "mask_present" "trace_strength" "p_correct" "rt_ms"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    @printf("Sensory trace simulation complete: %d trials\n", n)
    @printf("Mean trace strength: %.3f\n", mean(Float64.(rows[:, 7])))
    @printf("Mean report probability: %.3f\n", mean(Float64.(rows[:, 8])))
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
