fn within_capacity(allocations: &[f64], capacity: f64) -> bool {
    allocations.iter().sum::<f64>() <= capacity
}

fn main() {
    let allocations = vec![0.2, 0.3, 0.4];
    println!("Within capacity: {}", within_capacity(&allocations, 1.0));
}
