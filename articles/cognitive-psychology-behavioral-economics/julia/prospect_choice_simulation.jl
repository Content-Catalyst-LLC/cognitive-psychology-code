#!/usr/bin/env julia

# Cognitive psychology and behavioral economics.
# Julia simulation of prospect-theory value, loss aversion,
# framing, and intertemporal choice.

using Random
using Statistics
using Printf
using DelimitedFiles

function prospect_value(x; α=0.88, β=0.88, λ=2.25)
    if x >= 0
        return x^α
    else
        return -λ * ((-x)^β)
    end
end

function hyperbolic_discount(amount, delay; k=0.015)
    return amount / (1.0 + k * delay)
end

function logistic(x)
    return 1.0 / (1.0 + exp(-clamp(x, -40.0, 40.0)))
end

function simulate_trial(rng::AbstractRNG)
    frame = rand(rng) < 0.5 ? "gain" : "loss"
    amount = (frame == "loss" ? -1.0 : 1.0) * (20.0 + 180.0 * rand(rng))
    probability = 0.05 + 0.90 * rand(rng)
    delay = rand(rng, [0.0, 7.0, 14.0, 30.0, 90.0, 180.0, 365.0])
    λ = clamp(2.25 + 0.35 * randn(rng), 1.05, 4.0)
    cognitive_load = 10.0 * rand(rng)

    v = prospect_value(amount; λ=λ)
    discounted = hyperbolic_discount(abs(amount), delay)

    risky_prob = logistic(
        -0.8 +
        0.018 * v +
        0.90 * probability -
        0.10 * cognitive_load -
        0.003 * delay +
        (frame == "loss" ? 0.55 : 0.0)
    )

    risky_choice = rand(rng) < risky_prob ? 1 : 0

    return (
        frame = frame,
        amount = amount,
        probability = probability,
        delay = delay,
        lambda = λ,
        cognitive_load = cognitive_load,
        prospect_value = v,
        discounted_value = discounted,
        risky_choice = risky_choice
    )
end

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_prospect_choice_simulation.csv")
    rng = MersenneTwister(seed)
    rows = Matrix{Any}(undef, n, 9)

    for i in 1:n
        r = simulate_trial(rng)
        rows[i, :] = [
            i,
            r.frame,
            r.amount,
            r.probability,
            r.delay,
            r.lambda,
            r.cognitive_load,
            r.prospect_value,
            r.risky_choice
        ]
    end

    header = ["trial" "frame" "amount" "probability" "delay_days" "loss_aversion_lambda" "cognitive_load" "prospect_value" "risky_choice"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    choices = Float64.(rows[:, 9])
    loads = Float64.(rows[:, 7])
    lambdas = Float64.(rows[:, 6])

    @printf("Simulation complete: %d trials\n", n)
    @printf("Risky choice rate: %.3f\n", mean(choices))
    @printf("Mean cognitive load: %.3f\n", mean(loads))
    @printf("Mean loss-aversion lambda: %.3f\n", mean(lambdas))
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
