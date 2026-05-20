#!/usr/bin/env julia

# Cognitive constraints in organizational decision making.
# Julia simulation of bounded organizational choice using perceived value,
# effort cost, institutional salience, and cognitive burden.

using Random
using Statistics
using Printf
using DelimitedFiles

struct DecisionOption
    value::Float64
    effort::Float64
    salience::Float64
end

function softmax_choice(options::Vector{DecisionOption}; βv=1.0, βe=0.55, βs=0.75)
    utilities = [βv * o.value - βe * o.effort + βs * o.salience for o in options]
    maxu = maximum(utilities)
    weights = exp.(utilities .- maxu)
    probs = weights ./ sum(weights)
    return probs
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

function simulate_decision(rng::AbstractRNG; overload=false)
    n_options = overload ? rand(rng, 6:12) : rand(rng, 3:6)

    options = DecisionOption[]
    for _ in 1:n_options
        value = randn(rng) * 0.8 + 5.0
        effort = overload ? rand(rng) * 7.0 + 2.0 : rand(rng) * 4.0 + 1.0
        salience = rand(rng) * 6.0
        push!(options, DecisionOption(value, effort, salience))
    end

    probs = softmax_choice(options)
    chosen_idx = sample_index(rng, probs)
    best_value_idx = argmax([o.value for o in options])

    chosen = options[chosen_idx]
    best = options[best_value_idx]

    quality_gap = best.value - chosen.value
    satisficing = chosen_idx != best_value_idx && chosen.effort < mean([o.effort for o in options])

    return (
        n_options = n_options,
        chosen_value = chosen.value,
        best_value = best.value,
        quality_gap = quality_gap,
        chosen_effort = chosen.effort,
        chosen_salience = chosen.salience,
        satisficing = satisficing ? 1 : 0
    )
end

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_choice_simulation.csv")
    rng = MersenneTwister(seed)
    rows = Matrix{Any}(undef, n, 8)

    for i in 1:n
        overload = rand(rng) < 0.5
        result = simulate_decision(rng; overload=overload)

        rows[i, :] = [
            i,
            overload ? "overload" : "baseline",
            result.n_options,
            result.chosen_value,
            result.best_value,
            result.quality_gap,
            result.chosen_effort,
            result.satisficing
        ]
    end

    header = ["trial" "condition" "n_options" "chosen_value" "best_value" "quality_gap" "chosen_effort" "satisficing"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    gaps = Float64.(rows[:, 6])
    sats = Float64.(rows[:, 8])

    @printf("Simulation complete: %d trials\n", n)
    @printf("Mean quality gap: %.3f\n", mean(gaps))
    @printf("Satisficing rate: %.3f\n", mean(sats))
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
