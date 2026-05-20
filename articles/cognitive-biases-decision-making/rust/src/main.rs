use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    confidence_sum: f64,
    accuracy_sum: f64,
    calibration_sum: f64,
    overconfidence_sum: f64,
    risky_sum: f64,
    correct_sum: f64,
    quality_sum: f64,
    review_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/cognitive_bias_trials.csv");
        std::process::exit(1);
    }

    let content = fs::read_to_string(&args[1]).expect("Could not read CSV file");
    let mut lines = content.lines();
    let header_line = lines.next().expect("Missing header");
    let headers: Vec<&str> = header_line.split(',').collect();

    let idx = |name: &str| -> usize {
        headers.iter().position(|h| *h == name).unwrap_or_else(|| panic!("Missing column: {}", name))
    };

    let bias_i = idx("bias_type");
    let confidence_i = idx("confidence_rating");
    let accuracy_i = idx("actual_accuracy");
    let calibration_i = idx("calibration_error");
    let overconfidence_i = idx("overconfidence");
    let risky_i = idx("chose_risky");
    let correct_i = idx("correct");
    let quality_i = idx("decision_quality");
    let review_i = idx("institutional_review_flag");

    let mut summaries: HashMap<String, Summary> = HashMap::new();

    for line in lines {
        if line.trim().is_empty() {
            continue;
        }
        let fields: Vec<&str> = line.split(',').collect();
        let bias = fields[bias_i].to_string();
        let entry = summaries.entry(bias).or_default();
        entry.n += 1;
        entry.confidence_sum += parse_f64(fields[confidence_i]);
        entry.accuracy_sum += parse_f64(fields[accuracy_i]);
        entry.calibration_sum += parse_f64(fields[calibration_i]);
        entry.overconfidence_sum += parse_f64(fields[overconfidence_i]);
        entry.risky_sum += parse_f64(fields[risky_i]);
        entry.correct_sum += parse_f64(fields[correct_i]);
        entry.quality_sum += parse_f64(fields[quality_i]);
        entry.review_sum += parse_f64(fields[review_i]);
    }

    println!("BiasType,Trials,MeanConfidence,MeanAccuracy,MeanCalibrationError,MeanOverconfidence,RiskyChoiceRate,CorrectRate,MeanDecisionQuality,ReviewFlagRate");

    let mut keys: Vec<String> = summaries.keys().cloned().collect();
    keys.sort();

    for key in keys {
        let s = summaries.get(&key).unwrap();
        let n = s.n as f64;
        println!(
            "{},{},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3}",
            key,
            s.n,
            s.confidence_sum / n,
            s.accuracy_sum / n,
            s.calibration_sum / n,
            s.overconfidence_sum / n,
            s.risky_sum / n,
            s.correct_sum / n,
            s.quality_sum / n,
            s.review_sum / n
        );
    }
}
