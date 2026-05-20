#!/usr/bin/env julia

# Mental models in cognitive psychology.
# Julia simulation of prediction error and model revision.

using Random
using Statistics
using Printf
using DelimitedFiles

function clamp01(x)
    return min(max(x, 0.0), 1.0)
end

function simulate_trial(rng::AbstractRNG; condition="control")
    training = condition in ["model_training", "expert_comparison"] ? 1.0 : 0.0
    feedback = condition in ["feedback", "expert_comparison", "ai_assisted"] ? 1.0 : 0.0
    diagram = condition in ["diagram_prompt", "model_training"] ? 1.0 : 0.0
    ai = condition == "ai_assisted" ? 1.0 : 0.0
    complexity = condition == "complex_system" ? 7.5 + 2.0 * rand(rng) : 3.5 + 4.5 * rand(rng)

    skill = randn(rng)
    completeness = clamp(4.5 + 1.5 * training + 0.9 * diagram + 0.5 * skill + randn(rng), 0.0, 10.0)
    coherence = clamp(4.5 + 1.2 * training + 0.8 * diagram - 0.15 * complexity + 0.5 * skill + randn(rng), 0.0, 10.0)
    causal = clamp(4.5 + 1.3 * training + 1.0 * feedback - 0.12 * complexity + 0.5 * skill + randn(rng), 0.0, 10.0)
    loops = clamp(3.5 + 1.1 * training + 1.2 * feedback + 0.8 * diagram - 0.10 * complexity + 0.5 * skill + randn(rng), 0.0, 10.0)

    quality = 0.25 * completeness + 0.25 * coherence + 0.30 * causal + 0.20 * loops
    error_pre = clamp(30.0 - 2.4 * quality + 1.7 * complexity + 2.0 * randn(rng), 0.0, 100.0)
    revision_gain = clamp(0.30 * feedback * error_pre + 0.18 * training * error_pre + 0.12 * diagram * error_pre + 0.6 * skill + randn(rng), -10.0, 40.0)
    error_post = clamp(error_pre - revision_gain + 1.5 * ai * randn(rng), 0.0, 100.0)

    return (
        completeness = completeness,
        coherence = coherence,
        causal = causal,
        loops = loops,
        complexity = complexity,
        quality = quality,
        error_pre = error_pre,
        revision_gain = revision_gain,
        error_post = error_post
    )
end

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_model_revision.csv")
    rng = MersenneTwister(seed)
    conditions = ["control", "model_training", "diagram_prompt", "feedback", "expert_comparison", "complex_system", "ai_assisted"]
    rows = Matrix{Any}(undef, n, 10)

    for i in 1:n
        condition = rand(rng, conditions)
        r = simulate_trial(rng; condition=condition)
        rows[i, :] = [
            i,
            condition,
            r.completeness,
            r.coherence,
            r.causal,
            r.loops,
            r.complexity,
            r.error_pre,
            r.revision_gain,
            r.error_post
        ]
    end

    header = ["trial" "condition" "model_completeness" "model_coherence" "causal_link_accuracy" "feedback_loop_recognition" "complexity" "prediction_error_pre" "revision_gain" "prediction_error_post"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    @printf("Model-revision simulation complete: %d trials\n", n)
    @printf("Mean pre-feedback error: %.3f\n", mean(Float64.(rows[:, 8])))
    @printf("Mean revision gain: %.3f\n", mean(Float64.(rows[:, 9])))
    @printf("Mean post-feedback error: %.3f\n", mean(Float64.(rows[:, 10])))
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
