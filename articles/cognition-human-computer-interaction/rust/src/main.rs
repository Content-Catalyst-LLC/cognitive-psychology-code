use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    success_sum: f64,
    load_sum: f64,
    alignment_sum: f64,
    error_sum: f64,
    rt_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/hci_trials.csv");
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

    let condition_i = idx("interface_condition");
    let success_i = idx("success");
    let load_i = idx("cognitive_load");
    let alignment_i = idx("alignment_score");
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
        entry.success_sum += parse_f64(fields[success_i]);
        entry.load_sum += parse_f64(fields[load_i]);
        entry.alignment_sum += parse_f64(fields[alignment_i]);
        entry.error_sum += parse_f64(fields[error_i]);
        entry.rt_sum += parse_f64(fields[rt_i]);
    }

    println!("InterfaceCondition,Trials,SuccessRate,MeanCognitiveLoad,MeanAlignment,MeanErrors,MeanResponseTimeMs");

    let mut keys: Vec<String> = summaries.keys().cloned().collect();
    keys.sort();

    for key in keys {
        let s = summaries.get(&key).unwrap();
        let n = s.n as f64;
        println!(
            "{},{},{:.3},{:.3},{:.3},{:.3},{:.3}",
            key,
            s.n,
            s.success_sum / n,
            s.load_sum / n,
            s.alignment_sum / n,
            s.error_sum / n,
            s.rt_sum / n
        );
    }
}
