use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    intrinsic_sum: f64,
    extraneous_sum: f64,
    germane_sum: f64,
    effort_sum: f64,
    accuracy_sum: f64,
    correct_sum: f64,
    transfer_sum: f64,
    efficiency_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/cognitive_load_trials.csv");
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
    let intrinsic_i = idx("intrinsic_load");
    let extraneous_i = idx("extraneous_load");
    let germane_i = idx("germane_load");
    let effort_i = idx("subjective_effort");
    let accuracy_i = idx("performance_accuracy");
    let correct_i = idx("correct");
    let transfer_i = idx("transfer_score");
    let efficiency_i = idx("mental_efficiency");

    let mut summaries: HashMap<String, Summary> = HashMap::new();

    for line in lines {
        if line.trim().is_empty() {
            continue;
        }
        let fields: Vec<&str> = line.split(',').collect();
        let condition = fields[condition_i].to_string();
        let entry = summaries.entry(condition).or_default();
        entry.n += 1;
        entry.intrinsic_sum += parse_f64(fields[intrinsic_i]);
        entry.extraneous_sum += parse_f64(fields[extraneous_i]);
        entry.germane_sum += parse_f64(fields[germane_i]);
        entry.effort_sum += parse_f64(fields[effort_i]);
        entry.accuracy_sum += parse_f64(fields[accuracy_i]);
        entry.correct_sum += parse_f64(fields[correct_i]);
        entry.transfer_sum += parse_f64(fields[transfer_i]);
        entry.efficiency_sum += parse_f64(fields[efficiency_i]);
    }

    println!("Condition,Trials,MeanIntrinsic,MeanExtraneous,MeanGermane,MeanTotalLoad,MeanEffort,MeanAccuracy,CorrectRate,MeanTransfer,MeanEfficiency");

    let mut keys: Vec<String> = summaries.keys().cloned().collect();
    keys.sort();

    for key in keys {
        let s = summaries.get(&key).unwrap();
        let n = s.n as f64;
        let intrinsic = s.intrinsic_sum / n;
        let extraneous = s.extraneous_sum / n;
        let germane = s.germane_sum / n;
        println!(
            "{},{},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3}",
            key,
            s.n,
            intrinsic,
            extraneous,
            germane,
            intrinsic + extraneous + germane,
            s.effort_sum / n,
            s.accuracy_sum / n,
            s.correct_sum / n,
            s.transfer_sum / n,
            s.efficiency_sum / n
        );
    }
}
