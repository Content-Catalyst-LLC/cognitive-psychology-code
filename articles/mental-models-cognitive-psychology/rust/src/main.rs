use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    completeness_sum: f64,
    coherence_sum: f64,
    causal_sum: f64,
    loop_sum: f64,
    error_sum: f64,
    understanding_sum: f64,
    success_sum: f64,
    transfer_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/mental_models_trials.csv");
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
    let completeness_i = idx("model_completeness");
    let coherence_i = idx("model_coherence");
    let causal_i = idx("causal_link_accuracy");
    let loop_i = idx("feedback_loop_recognition");
    let error_i = idx("prediction_error");
    let understanding_i = idx("system_understanding_score");
    let success_i = idx("problem_success");
    let transfer_i = idx("transfer_score");

    let mut summaries: HashMap<String, Summary> = HashMap::new();

    for line in lines {
        if line.trim().is_empty() {
            continue;
        }
        let fields: Vec<&str> = line.split(',').collect();
        let condition = fields[condition_i].to_string();
        let entry = summaries.entry(condition).or_default();
        entry.n += 1;
        entry.completeness_sum += parse_f64(fields[completeness_i]);
        entry.coherence_sum += parse_f64(fields[coherence_i]);
        entry.causal_sum += parse_f64(fields[causal_i]);
        entry.loop_sum += parse_f64(fields[loop_i]);
        entry.error_sum += parse_f64(fields[error_i]);
        entry.understanding_sum += parse_f64(fields[understanding_i]);
        entry.success_sum += parse_f64(fields[success_i]);
        entry.transfer_sum += parse_f64(fields[transfer_i]);
    }

    println!("Condition,Trials,MeanCompleteness,MeanCoherence,MeanCausalAccuracy,MeanFeedbackLoopRecognition,MeanPredictionError,MeanUnderstanding,SuccessRate,MeanTransfer");

    let mut keys: Vec<String> = summaries.keys().cloned().collect();
    keys.sort();

    for key in keys {
        let s = summaries.get(&key).unwrap();
        let n = s.n as f64;
        println!(
            "{},{},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3}",
            key,
            s.n,
            s.completeness_sum / n,
            s.coherence_sum / n,
            s.causal_sum / n,
            s.loop_sum / n,
            s.error_sum / n,
            s.understanding_sum / n,
            s.success_sum / n,
            s.transfer_sum / n
        );
    }
}
