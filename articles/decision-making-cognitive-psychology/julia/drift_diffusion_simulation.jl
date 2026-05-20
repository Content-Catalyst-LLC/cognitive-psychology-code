#!/usr/bin/env julia

# Decision making in cognitive psychology.
# Julia simulation of drift-diffusion-style evidence accumulation.

using Random
using Statistics
using Printf
using DelimitedFiles

function simulate_trial(rng, drift, threshold, noise, dt, max_steps)
    x = 0.0
    for t in 1:max_steps
        x += drift * dt + noise * sqrt(dt) * randn(rng)
        if x >= threshold
            return 1, t * dt
        elseif x <= -threshold
            return 0, t * dt
        end
    end
    return x >= 0 ? 1 : 0, max_steps * dt
end

function run_simulation(; n=5000, seed=42, output_path="../outputs/julia_drift_diffusion.csv")
    rng = MersenneTwister(seed)
    rows = Matrix{Any}(undef, n, 9)

    correct_sum = 0
    rt_sum = 0.0

    for i in 1:n
        evidence_strength = clamp(randn(rng), -3.0, 3.0)
        time_pressure = 10.0 * rand(rng)
        uncertainty = 10.0 * rand(rng)
        threshold = clamp(1.2 + 0.08 * uncertainty - 0.06 * time_pressure, 0.45, 2.5)
        drift = 0.32 * evidence_strength - 0.04 * uncertainty
        noise = 1.0
        choice, rt = simulate_trial(rng, drift, threshold, noise, 0.01, 5000)
        criterion = evidence_strength >= 0 ? 1 : 0
        correct = choice == criterion ? 1 : 0

        correct_sum += correct
        rt_sum += rt

        rows[i, :] = [i, evidence_strength, time_pressure, uncertainty, threshold, drift, choice, rt, correct]
    end

    header = ["trial" "evidence_strength" "time_pressure" "uncertainty" "decision_threshold" "drift_rate" "choice" "response_time" "correct"]
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, header, ",")
        writedlm(io, rows, ",")
    end

    @printf("Drift-diffusion-style simulation complete: %d trials\n", n)
    @printf("Accuracy: %.3f\n", correct_sum / n)
    @printf("Mean response time: %.3f seconds\n", rt_sum / n)
    @printf("Output written to: %s\n", output_path)
end

run_simulation()
