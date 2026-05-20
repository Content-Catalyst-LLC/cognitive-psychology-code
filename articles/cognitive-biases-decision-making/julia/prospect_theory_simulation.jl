#!/usr/bin/env julia

# Cognitive biases in decision making.
# Julia simulation of prospect-theory subjective value and probability weighting.

using Random
using Statistics
using Printf
using DelimitedFiles

function probability_weight(p, gamma)
    p = clamp(p, 1e-6, 1.0 - 1e-6)
    return p^gamma / ((p^gamma + (1.0 - p)^gamma)^(1.0 / gamma))
end

function subjective_value(x, alpha, beta, lambda)
    if x >= 0
        return x^alpha
    else
        return -lambda * abs(x)^beta
    end
end

function logistic(x)
    return 1.0 / (1.0 + exp(-x))
end

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_prospect_theory.csv")
    rng = MersenneTwister(seed)
    rows = Matrix{Any}(undef, n, 10)

    risky_sum = 0
    loss_domain_sum = 0

    for i in 1:n
        p = rand(rng)
        payoff = rand(rng) < 0.5 ? 20 + 980 * rand(rng) : -(20 + 980 * rand(rng))
        lambda = clamp(2.2 + 0.35 * randn(rng), 0.8, 4.5)
        gamma = clamp(0.72 + 0.08 * randn(rng), 0.35, 1.0)
        w = probability_weight(p, gamma)
        sv = w * subjective_value(payoff, 0.88, 0.88, lambda)
        risky_prob = logistic(-0.45 + 0.007 * sv + 1.25 * w - 0.25 * lambda * (payoff < 0))
        chose_risky = rand(rng) < risky_prob ? 1 : 0

        risky_sum += chose_risky
        loss_domain_sum += payoff < 0 ? 1 : 0

        rows[i, :] = [i, p, payoff, lambda, gamma, w, sv, risky_prob, chose_risky, payoff < 0 ? 1 : 0]
    end

    header = ["trial" "probability" "payoff" "loss_aversion_lambda" "gamma" "probability_weight" "subjective_value" "risky_probability" "chose_risky" "loss_domain"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    @printf("Prospect-theory simulation complete: %d trials\n", n)
    @printf("Risky choice rate: %.3f\n", risky_sum / n)
    @printf("Loss-domain share: %.3f\n", loss_domain_sum / n)
    @printf("Mean subjective value: %.3f\n", mean(Float64.(rows[:, 7])))
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
