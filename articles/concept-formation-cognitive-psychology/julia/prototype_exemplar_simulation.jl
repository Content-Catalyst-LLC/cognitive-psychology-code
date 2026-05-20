#!/usr/bin/env julia

# Concept formation in cognitive psychology.
# Julia simulation of prototype distance, exemplar similarity, boundary ambiguity,
# and categorization accuracy.

using Random
using Statistics
using Printf
using DelimitedFiles
using LinearAlgebra

function logistic(x)
    return 1.0 / (1.0 + exp(-clamp(x, -40.0, 40.0)))
end

function distance(a, b)
    return norm(a .- b)
end

function simulate_category_learning(; n=4000, seed=42, output_path="../outputs/julia_prototype_exemplar_simulation.csv")
    rng = MersenneTwister(seed)

    prototypes = Dict(
        "Category_A" => [0.2, 0.2],
        "Category_B" => [0.8, 0.2],
        "Category_C" => [0.5, 0.8]
    )

    labels = collect(keys(prototypes))
    rows = Matrix{Any}(undef, n, 9)

    for trial in 1:n
        label = rand(rng, labels)
        prototype = prototypes[label]

        noise_scale = rand(rng) < 0.20 ? 0.28 : 0.12
        x = prototype .+ noise_scale .* randn(rng, 2)

        distances = Dict(k => distance(x, v) for (k, v) in prototypes)
        sorted = sort(collect(distances), by = pair -> pair[2])
        predicted = sorted[1][1]
        prototype_distance = sorted[1][2]
        competing_distance = sorted[2][2]

        boundary_ambiguity = 1.0 - abs(competing_distance - prototype_distance) / (competing_distance + prototype_distance + 1e-6)
        feature_diagnosticity = clamp(1.0 - prototype_distance + 0.1 * randn(rng), 0.0, 1.0)
        exemplar_similarity = exp(-3.0 * prototype_distance)

        accuracy_prob = logistic(
            1.4 -
            3.2 * prototype_distance +
            1.4 * competing_distance +
            2.0 * exemplar_similarity +
            1.2 * feature_diagnosticity -
            2.3 * boundary_ambiguity
        )

        accuracy = rand(rng) < accuracy_prob ? 1 : 0
        generalization = clamp(40.0 + 38.0 * accuracy_prob + 15.0 * feature_diagnosticity - 14.0 * boundary_ambiguity + 6.0 * randn(rng), 0.0, 100.0)

        rows[trial, :] = [
            trial,
            label,
            predicted,
            x[1],
            x[2],
            prototype_distance,
            competing_distance,
            boundary_ambiguity,
            generalization
        ]
    end

    header = ["trial" "true_category" "predicted_category" "x1" "x2" "prototype_distance" "nearest_competing_distance" "boundary_ambiguity" "generalization_score"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    @printf("Prototype/exemplar simulation complete: %d trials\n", n)
    @printf("Mean prototype distance: %.3f\n", mean(Float64.(rows[:, 6])))
    @printf("Mean boundary ambiguity: %.3f\n", mean(Float64.(rows[:, 8])))
    @printf("Mean generalization score: %.3f\n", mean(Float64.(rows[:, 9])))
    @printf("Output written to: %s\n", output_path)
end

simulate_category_learning()
