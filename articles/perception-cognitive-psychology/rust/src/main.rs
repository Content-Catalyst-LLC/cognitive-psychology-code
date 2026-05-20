use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    correct_sum: f64,
    yes_sum: f64,
    confidence_sum: f64,
    rt_sum: f64,
    evidence_sum: f64,
    prediction_error_sum: f64,
    threshold_sum: f64,
    noise_sum: f64,
    attention_sum: f64,
    context_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/perception_trials.csv");
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
    let correct_i = idx("correct");
    let yes_i = idx("response_yes");
    let confidence_i = idx("confidence");
    let rt_i = idx("response_time_ms");
    let evidence_i = idx("sensory_evidence");
    let pe_i = idx("prediction_error");
    let threshold_i = idx("perceptual_threshold");
    let noise_i = idx("noise_level");
    let attention_i = idx("attention_gain");
    let context_i = idx("context_strength");

    let mut summaries: HashMap<String, Summary> = HashMap::new();

    for line in lines {
        if line.trim().is_empty() { continue; }
        let fields: Vec<&str> = line.split(',').collect();
        let condition = fields[condition_i].to_string();
        let entry = summaries.entry(condition).or_default();
        entry.n += 1;
        entry.correct_sum += parse_f64(fields[correct_i]);
        entry.yes_sum += parse_f64(fields[yes_i]);
        entry.confidence_sum += parse_f64(fields[confidence_i]);
        entry.rt_sum += parse_f64(fields[rt_i]);
        entry.evidence_sum += parse_f64(fields[evidence_i]);
        entry.prediction_error_sum += parse_f64(fields[pe_i]);
        entry.threshold_sum += parse_f64(fields[threshold_i]);
        entry.noise_sum += parse_f64(fields[noise_i]);
        entry.attention_sum += parse_f64(fields[attention_i]);
        entry.context_sum += parse_f64(fields[context_i]);
    }

    println!("Condition,Trials,CorrectRate,YesRate,MeanConfidence,MeanRTms,MeanEvidence,MeanPredictionError,MeanThreshold,MeanNoise,MeanAttention,MeanContext");

    let mut keys: Vec<String> = summaries.keys().cloned().collect();
    keys.sort();

    for key in keys {
        let s = summaries.get(&key).unwrap();
        let n = s.n as f64;
        println!(
            "{},{},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3}",
            key, s.n, s.correct_sum / n, s.yes_sum / n, s.confidence_sum / n,
            s.rt_sum / n, s.evidence_sum / n, s.prediction_error_sum / n,
            s.threshold_sum / n, s.noise_sum / n, s.attention_sum / n, s.context_sum / n
        );
    }
}
