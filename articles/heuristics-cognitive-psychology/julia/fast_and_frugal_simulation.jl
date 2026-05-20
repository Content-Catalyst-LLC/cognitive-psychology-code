#!/usr/bin/env julia

# Heuristics in cognitive psychology.
# Julia simulation of weighted-additive, tallying, and take-the-best strategies.

using Random
using Statistics
using Printf
using DelimitedFiles

function logistic(x)
    return 1.0 / (1.0 + exp(-x))
end

function take_the_best(cues_a, cues_b, validities)
    order = sortperm(validities, rev=true)
    inspected = 0
    for idx in order
        inspected += 1
        if cues_a[idx] != cues_b[idx]
            return cues_a[idx] > cues_b[idx] ? 1 : 0, inspected
        end
    end
    return 1, inspected
end

function tally(cues_a, cues_b)
    return sum(cues_a) >= sum(cues_b) ? 1 : 0
end

function weighted_additive(cues_a, cues_b, validities)
    return sum(cues_a .* validities) >= sum(cues_b .* validities) ? 1 : 0
end

function run_simulation(; n=5000, k=8, seed=42, output_path="../outputs/julia_fast_and_frugal.csv")
    rng = MersenneTwister(seed)
    rows = Matrix{Any}(undef, n, 11)

    ttb_correct = 0
    tally_correct = 0
    wadd_correct = 0
    inspected_sum = 0

    validities = sort(rand(rng, k) .* 0.55 .+ 0.40, rev=true)

    for i in 1:n
        cues_a = rand(rng, [0, 1], k)
        cues_b = rand(rng, [0, 1], k)

        latent_a = sum(cues_a .* validities) + 0.25 * randn(rng)
        latent_b = sum(cues_b .* validities) + 0.25 * randn(rng)
        criterion = latent_a >= latent_b ? 1 : 0

        ttb_choice, inspected = take_the_best(cues_a, cues_b, validities)
        tally_choice = tally(cues_a, cues_b)
        wadd_choice = weighted_additive(cues_a, cues_b, validities)

        ttb_correct += ttb_choice == criterion ? 1 : 0
        tally_correct += tally_choice == criterion ? 1 : 0
        wadd_correct += wadd_choice == criterion ? 1 : 0
        inspected_sum += inspected

        rows[i, :] = [i, criterion, ttb_choice, tally_choice, wadd_choice, inspected, sum(cues_a), sum(cues_b), latent_a, latent_b, validities[1]]
    end

    header = ["trial" "criterion" "take_the_best" "tally" "weighted_additive" "ttb_cues_inspected" "cue_sum_a" "cue_sum_b" "latent_a" "latent_b" "top_cue_validity"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    @printf("Fast-and-frugal simulation complete: %d trials\n", n)
    @printf("Take-the-best accuracy: %.3f\n", ttb_correct / n)
    @printf("Tallying accuracy: %.3f\n", tally_correct / n)
    @printf("Weighted-additive accuracy: %.3f\n", wadd_correct / n)
    @printf("Mean cues inspected by take-the-best: %.3f\n", inspected_sum / n)
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
