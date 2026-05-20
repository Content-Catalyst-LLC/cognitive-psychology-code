use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    accuracy_sum: f64,
    comprehension_sum: f64,
    transfer_sum: f64,
    retention_sum: f64,
    load_sum: f64,
    gain_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/cognitive_learning_trials.csv");
        std::process::exit(1);
    }

    let content = fs::read_to_string(&args[1]).expect("Could not read CSV file");
    let mut lines = content.lines();
    let header_line = lines.next().expect("Missing header");
    let headers: Vec<&str> = header_line.split(',').collect();

    let idx = |name: &str| -> usize {
        headers.iter().position(|h| *h == name).unwrap_or_else(|| panic!("Missing column: {}", name))
    };

    let condition_i = idx("condition");
    let accuracy_i = idx("accuracy");
    let comprehension_i = idx("comprehension_score");
    let transfer_i = idx("transfer_score");
    let retention_i = idx("retention_score");
    let load_i = idx("cognitive_load");
    let gain_i = idx("learning_gain");

    let mut summaries: HashMap<String, Summary> = HashMap::new();

    for line in lines {
        if line.trim().is_empty() { continue; }
        let fields: Vec<&str> = line.split(',').collect();
        let condition = fields[condition_i].to_string();
        let entry = summaries.entry(condition).or_default();
        entry.n += 1;
        entry.accuracy_sum += parse_f64(fields[accuracy_i]);
        entry.comprehension_sum += parse_f64(fields[comprehension_i]);
        entry.transfer_sum += parse_f64(fields[transfer_i]);
        entry.retention_sum += parse_f64(fields[retention_i]);
        entry.load_sum += parse_f64(fields[load_i]);
        entry.gain_sum += parse_f64(fields[gain_i]);
    }

    println!("Condition,Trials,MeanAccuracy,MeanComprehension,MeanTransfer,MeanRetention,MeanCognitiveLoad,MeanLearningGain");

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
            s.comprehension_sum / n,
            s.transfer_sum / n,
            s.retention_sum / n,
            s.load_sum / n,
            s.gain_sum / n
        );
    }
}
