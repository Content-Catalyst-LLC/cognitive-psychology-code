use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    risky_sum: f64,
    default_sum: f64,
    load_sum: f64,
    attention_sum: f64,
    wtp_sum: f64,
    time_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/behavioral_economics_trials.csv");
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
    let risky_i = idx("risky_choice");
    let default_i = idx("default_accepted");
    let load_i = idx("cognitive_load");
    let attention_i = idx("attention_score");
    let wtp_i = idx("willingness_to_pay");
    let time_i = idx("decision_time_ms");

    let mut summaries: HashMap<String, Summary> = HashMap::new();

    for line in lines {
        if line.trim().is_empty() {
            continue;
        }

        let fields: Vec<&str> = line.split(',').collect();
        let condition = fields[condition_i].to_string();

        let entry = summaries.entry(condition).or_default();
        entry.n += 1;
        entry.risky_sum += parse_f64(fields[risky_i]);
        entry.default_sum += parse_f64(fields[default_i]);
        entry.load_sum += parse_f64(fields[load_i]);
        entry.attention_sum += parse_f64(fields[attention_i]);
        entry.wtp_sum += parse_f64(fields[wtp_i]);
        entry.time_sum += parse_f64(fields[time_i]);
    }

    println!("Condition,Trials,RiskyChoiceRate,DefaultAcceptanceRate,MeanCognitiveLoad,MeanAttention,MeanWTP,MeanDecisionTimeMs");

    let mut keys: Vec<String> = summaries.keys().cloned().collect();
    keys.sort();

    for key in keys {
        let s = summaries.get(&key).unwrap();
        let n = s.n as f64;
        println!(
            "{},{},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3}",
            key,
            s.n,
            s.risky_sum / n,
            s.default_sum / n,
            s.load_sum / n,
            s.attention_sum / n,
            s.wtp_sum / n,
            s.time_sum / n
        );
    }
}
