#!/usr/bin/env julia
using Random, Statistics, Printf, DelimitedFiles

function run_simulation(; n_participants=120, sessions=12, seed=42, output_path="../outputs/julia_learning_curve.csv")
    rng = MersenneTwister(seed)
    levels = ["novice", "intermediate", "advanced", "expert"]
    rows = Matrix{Any}(undef, n_participants * sessions, 8)
    row = 1
    for p in 1:n_participants
        level = rand(rng, levels)
        pmax = level == "novice" ? 0.65 : level == "intermediate" ? 0.78 : level == "advanced" ? 0.88 : 0.94
        lambda = level == "novice" ? 0.18 : level == "intermediate" ? 0.14 : level == "advanced" ? 0.10 : 0.07
        for session in 1:sessions
            accuracy = clamp(pmax - 0.45 * exp(-lambda * session) + 0.03 * randn(rng), 0.0, 1.0)
            error_rate = clamp(1.0 - accuracy + 0.02 * randn(rng), 0.0, 1.0)
            rt = clamp(3500.0 * session^(-0.42) + 650.0 + 80.0 * randn(rng), 150.0, 100000.0)
            cognitive_load = clamp(8.5 - 4.0 * accuracy + 0.4 * randn(rng), 0.0, 10.0)
            automaticity = clamp(1.5 + 7.0 * accuracy - 0.45 * cognitive_load + 0.4 * randn(rng), 0.0, 10.0)
            rows[row, :] = [p, level, session, accuracy, error_rate, rt, cognitive_load, automaticity]
            row += 1
        end
    end
    mkpath(dirname(output_path))
    open(output_path, "w") do io
        writedlm(io, ["participant" "expertise_level" "session" "accuracy" "error_rate" "response_time_ms" "cognitive_load" "automaticity_score"], ",")
        writedlm(io, rows, ",")
    end
    @printf("Wrote %s\nMean accuracy %.3f\n", output_path, mean(Float64.(rows[:, 4])))
end

run_simulation()
