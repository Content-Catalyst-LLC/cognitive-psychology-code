use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    accuracy_sum: f64,
    success_sum: f64,
    explanation_sum: f64,
    entropy_sum: f64,
    calibration_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/cognitive_systems_trials.csv");
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

    let architecture_i = idx("architecture");
    let accuracy_i = idx("prediction_accuracy");
    let success_i = idx("action_success");
    let explanation_i = idx("explanation_score");
    let entropy_i = idx("policy_entropy");
    let calibration_i = idx("calibration_error");

    let mut summaries: HashMap<String, Summary> = HashMap::new();

    for line in lines {
        if line.trim().is_empty() {
            continue;
        }

        let fields: Vec<&str> = line.split(',').collect();
        let architecture = fields[architecture_i].to_string();

        let entry = summaries.entry(architecture).or_default();
        entry.n += 1;
        entry.accuracy_sum += parse_f64(fields[accuracy_i]);
        entry.success_sum += parse_f64(fields[success_i]);
        entry.explanation_sum += parse_f64(fields[explanation_i]);
        entry.entropy_sum += parse_f64(fields[entropy_i]);
        entry.calibration_sum += parse_f64(fields[calibration_i]);
    }

    println!("Architecture,Trials,MeanAccuracy,SuccessRate,MeanExplanation,MeanEntropy,MeanCalibrationError");

    let mut keys: Vec<String> = summaries.keys().cloned().collect();
    keys.sort();

    for key in keys {
        let s = summaries.get(&key).unwrap();
        let n = s.n as f64;
        println!(
            "{},{},{:.3},{:.3},{:.3},{:.3},{:.3}",
            key,
            s.n,
            s.accuracy_sum / n,
            s.success_sum / n,
            s.explanation_sum / n,
            s.entropy_sum / n,
            s.calibration_sum / n
        );
    }
}
