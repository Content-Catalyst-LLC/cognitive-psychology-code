use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    correct_sum: f64,
    effort_sum: f64,
    rt_sum: f64,
    calibration_sum: f64,
    bias_sum: f64,
    adaptive_sum: f64,
    cue_count_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/heuristics_trials.csv");
        std::process::exit(1);
    }

    let content = fs::read_to_string(&args[1]).expect("Could not read CSV file");
    let mut lines = content.lines();
    let header_line = lines.next().expect("Missing header");
    let headers: Vec<&str> = header_line.split(',').collect();

    let idx = |name: &str| -> usize {
        headers.iter().position(|h| *h == name).unwrap_or_else(|| panic!("Missing column: {}", name))
    };

    let heuristic_i = idx("heuristic_type");
    let correct_i = idx("correct");
    let effort_i = idx("subjective_effort");
    let rt_i = idx("rt_ms");
    let calibration_i = idx("calibration_error");
    let bias_i = idx("bias_magnitude");
    let adaptive_i = idx("adaptive_fit");
    let cue_count_i = idx("cue_count");

    let mut summaries: HashMap<String, Summary> = HashMap::new();

    for line in lines {
        if line.trim().is_empty() {
            continue;
        }
        let fields: Vec<&str> = line.split(',').collect();
        let heuristic = fields[heuristic_i].to_string();
        let entry = summaries.entry(heuristic).or_default();
        entry.n += 1;
        entry.correct_sum += parse_f64(fields[correct_i]);
        entry.effort_sum += parse_f64(fields[effort_i]);
        entry.rt_sum += parse_f64(fields[rt_i]);
        entry.calibration_sum += parse_f64(fields[calibration_i]);
        entry.bias_sum += parse_f64(fields[bias_i]);
        entry.adaptive_sum += parse_f64(fields[adaptive_i]);
        entry.cue_count_sum += parse_f64(fields[cue_count_i]);
    }

    println!("Heuristic,Trials,CorrectRate,MeanEffort,MeanRTms,MeanCalibrationError,MeanBiasMagnitude,MeanAdaptiveFit,MeanCueCount");

    let mut keys: Vec<String> = summaries.keys().cloned().collect();
    keys.sort();

    for key in keys {
        let s = summaries.get(&key).unwrap();
        let n = s.n as f64;
        println!(
            "{},{},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3}",
            key,
            s.n,
            s.correct_sum / n,
            s.effort_sum / n,
            s.rt_sum / n,
            s.calibration_sum / n,
            s.bias_sum / n,
            s.adaptive_sum / n,
            s.cue_count_sum / n
        );
    }
}
