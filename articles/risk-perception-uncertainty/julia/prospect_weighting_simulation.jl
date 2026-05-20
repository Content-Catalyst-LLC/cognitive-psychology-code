#!/usr/bin/env julia

# Risk perception and uncertainty.
# Julia simulation of prospect-theory value and probability weighting.

using Random
using Statistics
using Printf
using DelimitedFiles

function prelec_weight(p, gamma)
    p = clamp(p, 1e-6, 1 - 1e-6)
    return exp(-((-log(p))^gamma))
end

function prospect_value(x, alpha, beta, lambda)
    if x >= 0
        return x^alpha
    else
        return -lambda * ((-x)^beta)
    end
end

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_prospect_weighting.csv")
    rng = MersenneTwister(seed)
    rows = Matrix{Any}(undef, n, 9)

    for i in 1:n
        p = clamp(rand(rng)^2, 0.001, 0.95)
        outcome = rand(rng) < 0.5 ? -100.0 * rand(rng) : 100.0 * rand(rng)
        alpha = 0.88
        beta = 0.88
        lambda = 2.25 + 0.25 * randn(rng)
        gamma = clamp(0.72 + 0.08 * randn(rng), 0.45, 0.95)

        w = prelec_weight(p, gamma)
        v = prospect_value(outcome, alpha, beta, lambda)
        subjective_value = w * v
        expected_value = p * outcome
        distortion = w - p

        perceived_risk = outcome < 0 ? clamp(abs(subjective_value) / 10.0, 0.0, 10.0) : clamp(10.0 - subjective_value / 10.0, 0.0, 10.0)

        rows[i, :] = [i, p, w, distortion, outcome, expected_value, v, subjective_value, perceived_risk]
    end

    header = ["trial" "objective_probability" "weighted_probability" "probability_distortion" "outcome" "expected_value" "prospect_value" "subjective_value" "perceived_risk"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    @printf("Prospect-weighting simulation complete: %d trials\n", n)
    @printf("Mean probability distortion: %.3f\n", mean(Float64.(rows[:, 4])))
    @printf("Mean perceived risk: %.3f\n", mean(Float64.(rows[:, 9])))
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
