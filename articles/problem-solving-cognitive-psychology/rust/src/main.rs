use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    accuracy_sum: f64,
    quality_sum: f64,
    representation_sum: f64,
    wm_sum: f64,
    error_sum: f64,
    rt_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/problem_solving_trials.csv");
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
    let accuracy_i = idx("solution_accuracy");
    let quality_i = idx("solution_quality");
    let representation_i = idx("representation_quality");
    let wm_i = idx("wm_load");
    let error_i = idx("error_count");
    let rt_i = idx("response_time_ms");

    let mut summaries: HashMap<String, Summary> = HashMap::new();

    for line in lines {
        if line.trim().is_empty() {
            continue;
        }

        let fields: Vec<&str> = line.split(',').collect();
        let condition = fields[condition_i].to_string();

        let entry = summaries.entry(condition).or_default();
        entry.n += 1;
        entry.accuracy_sum += parse_f64(fields[accuracy_i]);
        entry.quality_sum += parse_f64(fields[quality_i]);
        entry.representation_sum += parse_f64(fields[representation_i]);
        entry.wm_sum += parse_f64(fields[wm_i]);
        entry.error_sum += parse_f64(fields[error_i]);
        entry.rt_sum += parse_f64(fields[rt_i]);
    }

    println!("Condition,Trials,AccuracyRate,MeanQuality,MeanRepresentation,MeanWMLoad,MeanErrors,MeanResponseTimeMs");

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
            s.quality_sum / n,
            s.representation_sum / n,
            s.wm_sum / n,
            s.error_sum / n,
            s.rt_sum / n
        );
    }
}
