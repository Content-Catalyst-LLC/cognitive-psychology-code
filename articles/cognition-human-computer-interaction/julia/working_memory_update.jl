# Toy working-memory update model.

previous_state = [0.20, 0.60, 0.10]
incoming = [0.90, 0.20, 0.70]
gate = [0.80, 0.30, 0.50]

new_state = gate .* incoming .+ (1 .- gate) .* previous_state

println("Updated working-memory state:")
println(new_state)
