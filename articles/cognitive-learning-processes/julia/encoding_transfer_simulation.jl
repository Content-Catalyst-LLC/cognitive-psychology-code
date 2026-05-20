#!/usr/bin/env julia

# Cognitive learning processes.
# Julia simulation of encoding, schema growth, cognitive load, retention, and transfer.

using Random
using Statistics
using Printf
using DelimitedFiles

function clamp01(x)
    return min(max(x, 0.0), 1.0)
end

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_encoding_transfer.csv")
    rng = MersenneTwister(seed)
    conditions = ["control", "retrieval_practice", "worked_example", "spaced_practice", "interleaving", "high_load", "feedback_rich"]
    rows = Matrix{Any}(undef, n, 10)

    for i in 1:n
        condition = rand(rng, conditions)
        session = rand(rng, 1:8)
        retrieval = condition in ["retrieval_practice", "spaced_practice", "interleaving", "feedback_rich"] ? 1.0 : 0.0
        load_penalty = condition == "high_load" ? 2.0 : 0.0
        feedback = condition == "feedback_rich" ? 8.5 + randn(rng) : 5.5 + randn(rng)

        prior = clamp(4.5 + 0.3 * session + randn(rng), 0.0, 10.0)
        attention = clamp(6.0 + randn(rng), 0.0, 10.0)
        cognitive_load = clamp(5.8 + load_penalty - 0.2 * prior - 0.1 * feedback + randn(rng), 0.0, 10.0)
        encoding = clamp(4.0 + 0.25 * prior + 0.25 * attention + 0.15 * feedback - 0.15 * cognitive_load + randn(rng), 0.0, 10.0)
        schema = clamp(3.5 + 0.35 * session + 0.25 * prior + 0.25 * encoding + 0.5 * retrieval + randn(rng), 0.0, 10.0)
        comprehension = clamp(25.0 + 3.0 * encoding + 2.6 * schema + 2.0 * feedback + 4.0 * retrieval - 2.0 * cognitive_load + 5.0 * randn(rng), 0.0, 100.0)
        transfer = clamp(18.0 + 0.42 * comprehension + 2.4 * schema + 4.0 * (condition == "interleaving") + 3.0 * retrieval - 1.6 * cognitive_load + 5.0 * randn(rng), 0.0, 100.0)
        retention = clamp(22.0 + 0.40 * comprehension + 5.0 * retrieval + 5.0 * (condition == "spaced_practice") - 1.4 * cognitive_load + 5.0 * randn(rng), 0.0, 100.0)

        rows[i, :] = [i, condition, session, prior, attention, cognitive_load, encoding, schema, transfer, retention]
    end

    header = ["trial" "condition" "session" "prior_knowledge" "attention_score" "cognitive_load" "encoding_quality" "schema_strength" "transfer_score" "retention_score"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    @printf("Encoding-transfer simulation complete: %d trials\n", n)
    @printf("Mean transfer score: %.3f\n", mean(Float64.(rows[:, 9])))
    @printf("Mean retention score: %.3f\n", mean(Float64.(rows[:, 10])))
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
