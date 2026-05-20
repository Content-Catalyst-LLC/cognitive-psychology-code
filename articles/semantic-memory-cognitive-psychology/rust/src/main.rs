use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    accuracy_sum: f64,
    distance_sum: f64,
    typicality_sum: f64,
    category_strength_sum: f64,
    confidence_sum: f64,
    rt_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/semantic_memory_trials.csv");
        std::process::exit(1);
    }

    let path = &args[1];
    let content = fs::read_to_string(path).expect("Could not read CSV file");
    let mut lines = content.lines();

    let header_line = lines.next().expect("Missing header");
    let headers: Vec<&str> = header_line.split(',').collect();

    let idx = |name: &str| -> usize {
        headers
            .iter()
            .position(|h| *h == name)
            .unwrap_or_else(|| panic!("Missing column: {}", name))
    };

    let condition_i = idx("condition");
    let accuracy_i = idx("verification_accuracy");
    let distance_i = idx("semantic_distance");
    let typicality_i = idx("category_typicality");
    let category_strength_i = idx("category_strength");
    let confidence_i = idx("confidence");
    let rt_i = idx("response_time_ms");

    let mut summaries: HashMap<String, Summary> = HashMap::new();

    for line in lines {
        if line.trim().is_empty() {
            continue;
        }

        let fields: Vec<&str> = line.split(',').collect();
        let condition = fields[condition_i].to_string();

        let entry = summaries.entry(condition).or_default();
        entry.n += 1;
        entry.accuracy_sum += parse_f64(fields[accuracy_i]);
        entry.distance_sum += parse_f64(fields[distance_i]);
        entry.typicality_sum += parse_f64(fields[typicality_i]);
        entry.category_strength_sum += parse_f64(fields[category_strength_i]);
        entry.confidence_sum += parse_f64(fields[confidence_i]);
        entry.rt_sum += parse_f64(fields[rt_i]);
    }

    println!("Condition,Trials,AccuracyRate,MeanSemanticDistance,MeanTypicality,MeanCategoryStrength,MeanConfidence,MeanResponseTimeMs");

    let mut keys: Vec<String> = summaries.keys().cloned().collect();
    keys.sort();

    for key in keys {
        let s = summaries.get(&key).unwrap();
        let n = s.n as f64;
        println!(
            "{},{},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3}",
            key,
            s.n,
            s.accuracy_sum / n,
            s.distance_sum / n,
            s.typicality_sum / n,
            s.category_strength_sum / n,
            s.confidence_sum / n,
            s.rt_sum / n
        );
    }
}
