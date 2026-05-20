#!/usr/bin/env julia

# Cognition in human-computer interaction.
# Julia simulation of cognitive load, interface alignment, and task success.

using Random
using Statistics
using Printf
using DelimitedFiles

struct InterfaceParams
    condition::String
    perceptual_load::Float64
    attentional_demand::Float64
    memory_load::Float64
    alignment::Float64
    accessibility_friction::Float64
end

function logistic(x::Float64)
    return 1.0 / (1.0 + exp(-clamp(x, -40.0, 40.0)))
end

function simulate_trial(rng::AbstractRNG, params::InterfaceParams)
    difficulty = rand(rng) * 7.0 + 2.0

    cognitive_load =
        0.25 * params.perceptual_load +
        0.28 * params.attentional_demand +
        0.25 * params.memory_load +
        0.18 * difficulty +
        0.12 * params.accessibility_friction -
        0.20 * params.alignment +
        2.0 +
        randn(rng) * 0.45

    success_prob = logistic(
        2.1 -
        0.28 * difficulty -
        0.35 * cognitive_load -
        0.16 * params.accessibility_friction +
        0.30 * params.alignment
    )

    success = rand(rng) < success_prob ? 1 : 0

    rt = exp(
        log(1900.0) +
        0.07 * difficulty +
        0.07 * cognitive_load -
        0.04 * params.alignment +
        randn(rng) * 0.12
    )

    return (
        difficulty = difficulty,
        cognitive_load = cognitive_load,
        success = success,
        response_time = rt
    )
end

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_hci_cognitive_load.csv")
    rng = MersenneTwister(seed)

    interfaces = [
        InterfaceParams("baseline", 4.5, 4.6, 4.6, 6.5, 2.4),
        InterfaceParams("cluttered", 8.0, 7.5, 6.2, 4.5, 4.8),
        InterfaceParams("guided", 3.7, 3.8, 4.1, 8.0, 1.8),
        InterfaceParams("adaptive", 4.2, 4.4, 5.0, 7.4, 2.2),
        InterfaceParams("accessible", 3.5, 3.7, 4.4, 8.3, 1.1),
        InterfaceParams("ai_assisted", 4.3, 5.0, 5.4, 7.1, 2.0)
    ]

    rows = Matrix{Any}(undef, n, 6)

    for i in 1:n
        params = interfaces[rand(rng, eachindex(interfaces))]
        r = simulate_trial(rng, params)
        rows[i, :] = [
            i,
            params.condition,
            r.difficulty,
            r.cognitive_load,
            r.success,
            r.response_time
        ]
    end

    header = ["trial" "interface_condition" "task_difficulty" "cognitive_load" "success" "response_time_ms"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    success = Float64.(rows[:, 5])
    load_values = Float64.(rows[:, 4])
    rt_values = Float64.(rows[:, 6])

    @printf("Simulation complete: %d trials\n", n)
    @printf("Success rate: %.3f\n", mean(success))
    @printf("Mean cognitive load: %.3f\n", mean(load_values))
    @printf("Mean response time: %.3f ms\n", mean(rt_values))
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
