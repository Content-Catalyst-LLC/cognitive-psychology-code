#!/usr/bin/env julia

# Semantic memory in cognitive psychology.
# Julia simulation of semantic distance, weighted networks, and spreading activation.

using Random
using Statistics
using LinearAlgebra
using Printf
using DelimitedFiles

function normalize_columns(W)
    Wn = copy(W)
    for j in 1:size(W, 2)
        s = sum(Wn[:, j])
        if s > 0
            Wn[:, j] ./= s
        end
    end
    return Wn
end

function spreading_activation(W, start_idx; gamma=0.85, steps=5)
    n = size(W, 1)
    a = zeros(n)
    a[start_idx] = 1.0
    Wn = normalize_columns(W)

    for _ in 1:steps
        a = gamma .* Wn * a
    end

    return a
end

function run_simulation(; output_path="../outputs/julia_spreading_activation.csv")
    concepts = ["animal", "bird", "robin", "ostrich", "dog", "shark", "tool", "hammer", "wrench", "kitchen", "spoon", "doctor", "nurse", "scalpel", "justice", "law", "democracy"]
    idx = Dict(c => i for (i, c) in enumerate(concepts))
    n = length(concepts)
    W = zeros(n, n)

    edges = [
        ("animal", "bird", 0.80),
        ("bird", "robin", 0.92),
        ("bird", "ostrich", 0.55),
        ("animal", "dog", 0.85),
        ("animal", "shark", 0.72),
        ("tool", "hammer", 0.90),
        ("tool", "wrench", 0.86),
        ("kitchen", "spoon", 0.82),
        ("doctor", "nurse", 0.86),
        ("doctor", "scalpel", 0.70),
        ("justice", "law", 0.84),
        ("democracy", "law", 0.62)
    ]

    for (a, b, w) in edges
        W[idx[a], idx[b]] = w
        W[idx[b], idx[a]] = w
    end

    cue = "bird"
    activation = spreading_activation(W, idx[cue]; gamma=0.85, steps=4)

    rows = Matrix{Any}(undef, n, 3)
    for i in 1:n
        rows[i, :] = [cue, concepts[i], activation[i]]
    end

    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, ["cue" "concept" "activation"], ",")
        writedlm(io, rows, ",")
    end

    sorted_idx = sortperm(activation, rev=true)
    @printf("Spreading activation from cue: %s\n", cue)
    for i in sorted_idx[1:min(6, n)]
        @printf("%s: %.4f\n", concepts[i], activation[i])
    end
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
