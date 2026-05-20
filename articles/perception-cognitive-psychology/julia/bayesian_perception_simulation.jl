#!/usr/bin/env julia
using Random
using Statistics
using Printf
using DelimitedFiles

function logistic(x)
    return 1.0 / (1.0 + exp(-x))
end

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_bayesian_perception.csv")
    rng = MersenneTwister(seed)
    rows = Matrix{Any}(undef, n, 10)
    correct_sum = 0
    pe_sum = 0.0

    for i in 1:n
        signal = rand(rng) < 0.55 ? 1 : 0
        sensory = clamp(randn(rng) + 1.2 * signal, -5.0, 5.0)
        prior = clamp(0.5 + 0.18 * randn(rng), 0.05, 0.95)
        noise = 0.5 + 2.0 * rand(rng)
        prediction = log(prior / (1 - prior))
        prediction_error = abs(sensory - prediction)
        posterior_logit = 1.1 * sensory + 0.8 * prediction - 0.25 * noise
        response = rand(rng) < logistic(posterior_logit) ? 1 : 0
        correct = response == signal ? 1 : 0
        confidence = clamp(0.45 + 0.22 * abs(posterior_logit) + 0.10 * correct, 0.0, 1.0)

        correct_sum += correct
        pe_sum += prediction_error
        rows[i, :] = [i, signal, sensory, prior, noise, prediction, prediction_error, response, correct, confidence]
    end

    header = ["trial" "signal_present" "sensory_evidence" "prior_probability" "noise_level" "prediction" "prediction_error" "response_yes" "correct" "confidence"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    @printf("Bayesian perception simulation complete: %d trials\n", n)
    @printf("Correct rate: %.3f\n", correct_sum / n)
    @printf("Mean prediction error: %.3f\n", pe_sum / n)
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
