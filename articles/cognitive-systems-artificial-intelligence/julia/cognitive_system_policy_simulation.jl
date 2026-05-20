#!/usr/bin/env julia

# Cognitive systems in artificial intelligence.
# Julia simulation of belief-state updating and policy selection under uncertainty.

using Random
using Statistics
using Printf
using DelimitedFiles

struct AgentParams
    architecture::String
    representation_quality::Float64
    explanation_quality::Float64
    policy_temperature::Float64
end

function softmax(values::Vector{Float64}, temperature::Float64)
    t = max(temperature, 0.05)
    scaled = values ./ t
    m = maximum(scaled)
    weights = exp.(scaled .- m)
    return weights ./ sum(weights)
end

function entropy(probs::Vector{Float64})
    return -sum(p > 0 ? p * log(p) : 0.0 for p in probs)
end

function sample_index(rng::AbstractRNG, probs::Vector{Float64})
    threshold = rand(rng)
    cumulative = 0.0
    for (i, p) in enumerate(probs)
        cumulative += p
        if threshold <= cumulative
            return i
        end
    end
    return length(probs)
end

function simulate_trial(rng::AbstractRNG, params::AgentParams; high_uncertainty=false)
    n_actions = high_uncertainty ? rand(rng, 5:9) : rand(rng, 3:5)
    true_values = randn(rng, n_actions) .+ 3.0
    uncertainty = high_uncertainty ? rand(rng) * 4.0 + 6.0 : rand(rng) * 4.0 + 2.0

    representation_noise = uncertainty / max(params.representation_quality, 0.5)
    estimated_values = true_values .+ randn(rng, n_actions) .* representation_noise

    probs = softmax(estimated_values, params.policy_temperature)
    chosen = sample_index(rng, probs)
    optimal = argmax(true_values)

    action_success = chosen == optimal ? 1 : 0
    policy_entropy = entropy(probs)
    quality_gap = maximum(true_values) - true_values[chosen]

    return (
        uncertainty = uncertainty,
        n_actions = n_actions,
        chosen = chosen,
        optimal = optimal,
        action_success = action_success,
        policy_entropy = policy_entropy,
        quality_gap = quality_gap
    )
end

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_policy_simulation.csv")
    rng = MersenneTwister(seed)

    agents = [
        AgentParams("symbolic", 7.0, 8.0, 0.75),
        AgentParams("neural", 7.8, 5.4, 1.05),
        AgentParams("hybrid", 8.5, 8.1, 0.70),
        AgentParams("retrieval_augmented", 8.2, 7.6, 0.72),
        AgentParams("reinforcement_learning", 6.8, 5.1, 1.20)
    ]

    rows = Matrix{Any}(undef, n, 8)

    for i in 1:n
        agent = agents[rand(rng, eachindex(agents))]
        high_uncertainty = rand(rng) < 0.45
        r = simulate_trial(rng, agent; high_uncertainty=high_uncertainty)

        rows[i, :] = [
            i,
            agent.architecture,
            high_uncertainty ? "high_uncertainty" : "baseline",
            r.uncertainty,
            r.n_actions,
            r.action_success,
            r.policy_entropy,
            r.quality_gap
        ]
    end

    header = ["trial" "architecture" "condition" "uncertainty" "n_actions" "action_success" "policy_entropy" "quality_gap"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    success = Float64.(rows[:, 6])
    entropy_values = Float64.(rows[:, 7])
    gaps = Float64.(rows[:, 8])

    @printf("Simulation complete: %d trials\n", n)
    @printf("Action success rate: %.3f\n", mean(success))
    @printf("Mean policy entropy: %.3f\n", mean(entropy_values))
    @printf("Mean quality gap: %.3f\n", mean(gaps))
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
