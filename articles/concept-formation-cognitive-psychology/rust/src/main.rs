use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    accuracy_sum: f64,
    prototype_distance_sum: f64,
    generalization_sum: f64,
    discrimination_sum: f64,
    abstraction_sum: f64,
    rt_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/concept_formation_trials.csv");
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
    let accuracy_i = idx("category_accuracy");
    let prototype_i = idx("prototype_distance");
    let generalization_i = idx("generalization_score");
    let discrimination_i = idx("discrimination_score");
    let abstraction_i = idx("abstraction_quality");
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
        entry.prototype_distance_sum += parse_f64(fields[prototype_i]);
        entry.generalization_sum += parse_f64(fields[generalization_i]);
        entry.discrimination_sum += parse_f64(fields[discrimination_i]);
        entry.abstraction_sum += parse_f64(fields[abstraction_i]);
        entry.rt_sum += parse_f64(fields[rt_i]);
    }

    println!("Condition,Trials,AccuracyRate,MeanPrototypeDistance,MeanGeneralization,MeanDiscrimination,MeanAbstractionQuality,MeanResponseTimeMs");

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
            s.prototype_distance_sum / n,
            s.generalization_sum / n,
            s.discrimination_sum / n,
            s.abstraction_sum / n,
            s.rt_sum / n
        );
    }
}
