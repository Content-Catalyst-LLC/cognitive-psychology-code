use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    risky_sum: f64,
    optimal_sum: f64,
    accuracy_sum: f64,
    confidence_sum: f64,
    quality_sum: f64,
    rt_sum: f64,
    load_sum: f64,
    uncertainty_sum: f64,
    regret_sum: f64,
    verification_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/decision_trials.csv");
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
    let risky_i = idx("choice_risky");
    let optimal_i = idx("optimal_choice");
    let accuracy_i = idx("accuracy");
    let confidence_i = idx("confidence");
    let quality_i = idx("decision_quality");
    let rt_i = idx("response_time_ms");
    let load_i = idx("cognitive_load");
    let uncertainty_i = idx("uncertainty");
    let regret_i = idx("regret");
    let verification_i = idx("verification_burden");

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
        entry.optimal_sum += parse_f64(fields[optimal_i]);
        entry.accuracy_sum += parse_f64(fields[accuracy_i]);
        entry.confidence_sum += parse_f64(fields[confidence_i]);
        entry.quality_sum += parse_f64(fields[quality_i]);
        entry.rt_sum += parse_f64(fields[rt_i]);
        entry.load_sum += parse_f64(fields[load_i]);
        entry.uncertainty_sum += parse_f64(fields[uncertainty_i]);
        entry.regret_sum += parse_f64(fields[regret_i]);
        entry.verification_sum += parse_f64(fields[verification_i]);
    }

    println!("Condition,Trials,RiskyChoiceRate,OptimalChoiceRate,MeanAccuracy,MeanConfidence,MeanDecisionQuality,MeanRTms,MeanLoad,MeanUncertainty,MeanRegret,MeanVerificationBurden");

    let mut keys: Vec<String> = summaries.keys().cloned().collect();
    keys.sort();

    for key in keys {
        let s = summaries.get(&key).unwrap();
        let n = s.n as f64;
        println!(
            "{},{},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3}",
            key,
            s.n,
            s.risky_sum / n,
            s.optimal_sum / n,
            s.accuracy_sum / n,
            s.confidence_sum / n,
            s.quality_sum / n,
            s.rt_sum / n,
            s.load_sum / n,
            s.uncertainty_sum / n,
            s.regret_sum / n,
            s.verification_sum / n
        );
    }
}
