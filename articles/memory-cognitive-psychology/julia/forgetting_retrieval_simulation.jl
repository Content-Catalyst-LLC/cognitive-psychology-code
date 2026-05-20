#!/usr/bin/env julia
using Random, Statistics, Printf, DelimitedFiles

logistic(x) = 1.0 / (1.0 + exp(-x))

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_forgetting_retrieval.csv")
    rng = MersenneTwister(seed)
    rows = Matrix{Any}(undef, n, 11)
    correct_sum = 0
    retrieval_sum = 0
    for i in 1:n
        retrieval_practice = rand(rng) < 0.5 ? 1 : 0
        spacing = retrieval_practice == 1 ? 4.0 * rand(rng) : 0.5 * rand(rng)
        delay = rand(rng, [0.25, 1.0, 3.0, 7.0, 14.0, 30.0])
        encoding_depth = clamp(5.5 + 1.5 * randn(rng), 0.0, 10.0)
        cue_quality = clamp(4.0 + 0.35 * encoding_depth + randn(rng), 0.0, 10.0)
        interference = clamp(3.0 + 2.0 * rand(rng), 0.0, 10.0)
        lambda = clamp(0.10 + 0.018 * interference - 0.012 * retrieval_practice - 0.006 * spacing + 0.02 * randn(rng), 0.01, 0.35)
        initial = clamp(0.35 + 0.06 * encoding_depth + 0.025 * cue_quality, 0.05, 1.25)
        strength = clamp(initial * exp(-lambda * delay) + 0.16 * retrieval_practice + 0.02 * spacing, 0.0, 1.8)
        recall_prob = logistic(-1.6 + 2.6 * strength + 0.16 * cue_quality - 0.20 * interference - 0.06 * delay / 7.0)
        correct = rand(rng) < recall_prob ? 1 : 0
        correct_sum += correct
        retrieval_sum += retrieval_practice
        rows[i, :] = [i, retrieval_practice, spacing, delay, encoding_depth, cue_quality, interference, lambda, strength, recall_prob, correct]
    end
    header = ["trial" "retrieval_practice" "spacing_interval" "delay" "encoding_depth" "cue_quality" "interference" "forgetting_rate" "retention_strength" "recall_probability" "correct"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end
    @printf("Forgetting and retrieval-practice simulation complete: %d trials\n", n)
    @printf("Correct rate: %.3f\n", correct_sum / n)
    @printf("Retrieval-practice share: %.3f\n", retrieval_sum / n)
end

run_simulation()
