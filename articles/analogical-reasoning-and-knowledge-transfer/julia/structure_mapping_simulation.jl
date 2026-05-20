#!/usr/bin/env julia

# Analogical reasoning and knowledge transfer.
# Julia simulation of structure mapping, relational complexity,
# surface similarity, and transfer success.

using Random
using Statistics
using Printf
using DelimitedFiles

function logistic(x)
    return 1.0 / (1.0 + exp(-clamp(x, -40.0, 40.0)))
end

function simulate_trial(rng::AbstractRNG; condition="control")
    if condition == "surface_match"
        surface = 7.5 + 2.0 * rand(rng)
        structure = 3.0 + 3.0 * rand(rng)
        cue = 0
    elseif condition == "structure_match"
        surface = 2.0 + 4.0 * rand(rng)
        structure = 7.0 + 2.5 * rand(rng)
        cue = 0
    elseif condition == "analogical_cue"
        surface = 3.0 + 4.0 * rand(rng)
        structure = 6.5 + 3.0 * rand(rng)
        cue = 1
    elseif condition == "high_complexity"
        surface = 3.0 + 5.0 * rand(rng)
        structure = 6.0 + 3.0 * rand(rng)
        cue = 0
    else
        surface = 3.0 + 5.0 * rand(rng)
        structure = 3.0 + 5.0 * rand(rng)
        cue = 0
    end

    complexity = condition == "high_complexity" ? 7.5 + 2.0 * rand(rng) : 3.0 + 5.0 * rand(rng)
    familiarity = 4.0 + 5.0 * rand(rng)
    working_memory = clamp(2.0 + 0.55 * complexity + randn(rng), 0.0, 10.0)

    mapping_prob = logistic(
        -2.0 +
        0.55 * structure +
        0.20 * familiarity +
        0.55 * cue -
        0.32 * complexity -
        0.18 * working_memory -
        0.08 * surface * (condition == "surface_match" ? 1.0 : 0.0)
    )

    mapping = rand(rng) < mapping_prob ? 1 : 0

    transfer_prob = logistic(
        -2.4 +
        0.62 * structure +
        0.75 * mapping +
        0.40 * cue -
        0.30 * complexity -
        0.18 * working_memory
    )

    transfer = rand(rng) < transfer_prob ? 1 : 0

    quality = clamp(35.0 + 5.0 * structure + 8.0 * mapping + 9.0 * transfer - 2.0 * complexity + 7.0 * randn(rng), 0.0, 100.0)

    return (
        surface = surface,
        structure = structure,
        complexity = complexity,
        familiarity = familiarity,
        working_memory = working_memory,
        cue = cue,
        mapping = mapping,
        transfer = transfer,
        quality = quality
    )
end

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_structure_mapping.csv")
    rng = MersenneTwister(seed)
    conditions = ["control", "surface_match", "structure_match", "analogical_cue", "high_complexity"]
    rows = Matrix{Any}(undef, n, 10)

    for i in 1:n
        condition = rand(rng, conditions)
        r = simulate_trial(rng; condition=condition)

        rows[i, :] = [
            i,
            condition,
            r.surface,
            r.structure,
            r.complexity,
            r.familiarity,
            r.working_memory,
            r.mapping,
            r.transfer,
            r.quality
        ]
    end

    header = ["trial" "condition" "surface_similarity" "structural_similarity" "relational_complexity" "source_familiarity" "working_memory_load" "mapping_accuracy" "transfer_success" "inference_quality"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    mapping = Float64.(rows[:, 8])
    transfer = Float64.(rows[:, 9])
    quality = Float64.(rows[:, 10])

    @printf("Simulation complete: %d trials\n", n)
    @printf("Mapping accuracy rate: %.3f\n", mean(mapping))
    @printf("Transfer success rate: %.3f\n", mean(transfer))
    @printf("Mean inference quality: %.3f\n", mean(quality))
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
