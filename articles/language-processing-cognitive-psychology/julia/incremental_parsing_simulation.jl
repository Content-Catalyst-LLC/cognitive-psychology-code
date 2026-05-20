#!/usr/bin/env julia

# Language processing in cognitive psychology.
# Julia simulation of incremental interpretation, syntactic complexity,
# semantic predictability, working-memory load, and reading time.

using Random
using Statistics
using Printf
using DelimitedFiles

function logistic(x)
    return 1.0 / (1.0 + exp(-clamp(x, -40.0, 40.0)))
end

function simulate_trial(rng::AbstractRNG; condition="control")
    if condition == "syntactic_complexity"
        word_frequency = 5.0 + 2.0 * rand(rng)
        syntax = 7.5 + 2.0 * rand(rng)
        predictability = 3.5 + 3.0 * rand(rng)
        context = 3.5 + 3.0 * rand(rng)
        pragmatic = 3.0 + 3.5 * rand(rng)
    elseif condition == "semantic_prime"
        word_frequency = 6.5 + 3.0 * rand(rng)
        syntax = 2.0 + 4.0 * rand(rng)
        predictability = 7.5 + 2.0 * rand(rng)
        context = 7.0 + 2.5 * rand(rng)
        pragmatic = 2.0 + 3.0 * rand(rng)
    elseif condition == "pragmatic_inference"
        word_frequency = 5.0 + 3.0 * rand(rng)
        syntax = 4.0 + 3.0 * rand(rng)
        predictability = 4.0 + 3.0 * rand(rng)
        context = 5.0 + 4.0 * rand(rng)
        pragmatic = 7.2 + 2.5 * rand(rng)
    else
        word_frequency = 3.0 + 6.0 * rand(rng)
        syntax = 3.0 + 5.0 * rand(rng)
        predictability = 3.0 + 6.0 * rand(rng)
        context = 3.0 + 6.0 * rand(rng)
        pragmatic = 2.0 + 5.0 * rand(rng)
    end

    ambiguity = 2.0 + 6.0 * rand(rng)
    wm_load = clamp(2.0 + 0.55 * syntax + 0.25 * ambiguity + 0.20 * pragmatic - 0.22 * context + randn(rng), 0.0, 10.0)
    discourse = clamp(0.5 * context + 0.4 * predictability + 1.5 * rand(rng), 0.0, 10.0)

    accuracy_prob = logistic(
        -1.0 +
        0.22 * word_frequency -
        0.24 * ambiguity -
        0.30 * syntax +
        0.24 * predictability +
        0.20 * context -
        0.24 * wm_load -
        0.18 * pragmatic +
        0.25 * discourse
    )

    accuracy = rand(rng) < accuracy_prob ? 1 : 0

    reading_time = exp(
        log(1200.0) -
        0.045 * word_frequency +
        0.060 * ambiguity +
        0.080 * syntax -
        0.045 * predictability -
        0.030 * context +
        0.065 * wm_load +
        0.025 * pragmatic -
        0.025 * accuracy +
        0.12 * randn(rng)
    )

    return (
        word_frequency = word_frequency,
        ambiguity = ambiguity,
        syntax = syntax,
        predictability = predictability,
        context = context,
        wm_load = wm_load,
        pragmatic = pragmatic,
        discourse = discourse,
        accuracy = accuracy,
        reading_time = reading_time
    )
end

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_incremental_parsing.csv")
    rng = MersenneTwister(seed)
    conditions = ["control", "syntactic_complexity", "semantic_prime", "pragmatic_inference"]
    rows = Matrix{Any}(undef, n, 11)

    for i in 1:n
        condition = rand(rng, conditions)
        r = simulate_trial(rng; condition=condition)

        rows[i, :] = [
            i,
            condition,
            r.word_frequency,
            r.ambiguity,
            r.syntax,
            r.predictability,
            r.context,
            r.wm_load,
            r.pragmatic,
            r.accuracy,
            r.reading_time
        ]
    end

    header = ["trial" "condition" "word_frequency" "lexical_ambiguity" "syntactic_complexity" "semantic_predictability" "context_support" "working_memory_load" "pragmatic_inference_demand" "comprehension_accuracy" "reading_time_ms"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    accuracy = Float64.(rows[:, 10])
    reading = Float64.(rows[:, 11])

    @printf("Incremental parsing simulation complete: %d trials\n", n)
    @printf("Comprehension accuracy rate: %.3f\n", mean(accuracy))
    @printf("Mean reading time: %.3f ms\n", mean(reading))
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
