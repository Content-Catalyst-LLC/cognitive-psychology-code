use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    objective_probability_sum: f64,
    subjective_probability_sum: f64,
    perceived_risk_sum: f64,
    affect_sum: f64,
    dread_sum: f64,
    trust_sum: f64,
    ambiguity_sum: f64,
    safe_sum: f64,
    action_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/risk_perception_trials.csv");
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
    let objective_i = idx("objective_probability");
    let subjective_i = idx("subjective_probability");
    let risk_i = idx("perceived_risk");
    let affect_i = idx("affect_rating");
    let dread_i = idx("dread_rating");
    let trust_i = idx("trust_rating");
    let ambiguity_i = idx("ambiguity_rating");
    let safe_i = idx("choose_safe");
    let action_i = idx("protective_action");

    let mut summaries: HashMap<String, Summary> = HashMap::new();

    for line in lines {
        if line.trim().is_empty() {
            continue;
        }
        let fields: Vec<&str> = line.split(',').collect();
        let condition = fields[condition_i].to_string();
        let entry = summaries.entry(condition).or_default();
        entry.n += 1;
        entry.objective_probability_sum += parse_f64(fields[objective_i]);
        entry.subjective_probability_sum += parse_f64(fields[subjective_i]);
        entry.perceived_risk_sum += parse_f64(fields[risk_i]);
        entry.affect_sum += parse_f64(fields[affect_i]);
        entry.dread_sum += parse_f64(fields[dread_i]);
        entry.trust_sum += parse_f64(fields[trust_i]);
        entry.ambiguity_sum += parse_f64(fields[ambiguity_i]);
        entry.safe_sum += parse_f64(fields[safe_i]);
        entry.action_sum += parse_f64(fields[action_i]);
    }

    println!("Condition,Trials,MeanObjectiveProbability,MeanSubjectiveProbability,MeanProbabilityDistortion,MeanRisk,MeanAffect,MeanDread,MeanTrust,MeanAmbiguity,SafeChoiceRate,ProtectiveActionRate");

    let mut keys: Vec<String> = summaries.keys().cloned().collect();
    keys.sort();

    for key in keys {
        let s = summaries.get(&key).unwrap();
        let n = s.n as f64;
        let obj = s.objective_probability_sum / n;
        let subj = s.subjective_probability_sum / n;
        println!(
            "{},{},{:.4},{:.4},{:.4},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3}",
            key,
            s.n,
            obj,
            subj,
            subj - obj,
            s.perceived_risk_sum / n,
            s.affect_sum / n,
            s.dread_sum / n,
            s.trust_sum / n,
            s.ambiguity_sum / n,
            s.safe_sum / n,
            s.action_sum / n
        );
    }
}
