use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    confidence_sum: f64,
    accuracy_sum: f64,
    calibration_sum: f64,
    shift_sum: f64,
    review_sum: f64,
    regulation_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/metacognition_trials.csv");
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
    let confidence_i = idx("confidence_rating");
    let accuracy_i = idx("actual_accuracy");
    let shift_i = idx("strategy_shift");
    let review_i = idx("review_choice");
    let regulation_i = idx("metacognitive_regulation_score");

    let mut summaries: HashMap<String, Summary> = HashMap::new();

    for line in lines {
        if line.trim().is_empty() {
            continue;
        }

        let fields: Vec<&str> = line.split(',').collect();
        let condition = fields[condition_i].to_string();
        let confidence = parse_f64(fields[confidence_i]);
        let accuracy = parse_f64(fields[accuracy_i]);

        let entry = summaries.entry(condition).or_default();
        entry.n += 1;
        entry.confidence_sum += confidence;
        entry.accuracy_sum += accuracy;
        entry.calibration_sum += (confidence - accuracy).abs();
        entry.shift_sum += parse_f64(fields[shift_i]);
        entry.review_sum += parse_f64(fields[review_i]);
        entry.regulation_sum += parse_f64(fields[regulation_i]);
    }

    println!("Condition,Trials,MeanConfidence,AccuracyRate,MeanCalibrationError,StrategyShiftRate,ReviewChoiceRate,MeanRegulationScore");

    let mut keys: Vec<String> = summaries.keys().cloned().collect();
    keys.sort();

    for key in keys {
        let s = summaries.get(&key).unwrap();
        let n = s.n as f64;
        println!(
            "{},{},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3}",
            key,
            s.n,
            s.confidence_sum / n,
            s.accuracy_sum / n,
            s.calibration_sum / n,
            s.shift_sum / n,
            s.review_sum / n,
            s.regulation_sum / n
        );
    }
}
