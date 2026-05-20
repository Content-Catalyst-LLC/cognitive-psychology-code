use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    correct_sum: f64,
    report_sum: f64,
    trace_sum: f64,
    selection_sum: f64,
    transfer_sum: f64,
    rt_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/sensory_memory_trials.csv");
        std::process::exit(1);
    }

    let content = fs::read_to_string(&args[1]).expect("Could not read CSV file");
    let mut lines = content.lines();
    let header_line = lines.next().expect("Missing header");
    let headers: Vec<&str> = header_line.split(',').collect();

    let idx = |name: &str| -> usize {
        headers.iter().position(|h| *h == name).unwrap_or_else(|| panic!("Missing column: {}", name))
    };

    let modality_i = idx("modality");
    let correct_i = idx("correct");
    let report_i = idx("report_score");
    let trace_i = idx("trace_strength");
    let selection_i = idx("selection_probability");
    let transfer_i = idx("wm_transfer");
    let rt_i = idx("rt_ms");

    let mut summaries: HashMap<String, Summary> = HashMap::new();

    for line in lines {
        if line.trim().is_empty() {
            continue;
        }
        let fields: Vec<&str> = line.split(',').collect();
        let modality = fields[modality_i].to_string();
        let entry = summaries.entry(modality).or_default();
        entry.n += 1;
        entry.correct_sum += parse_f64(fields[correct_i]);
        entry.report_sum += parse_f64(fields[report_i]);
        entry.trace_sum += parse_f64(fields[trace_i]);
        entry.selection_sum += parse_f64(fields[selection_i]);
        entry.transfer_sum += parse_f64(fields[transfer_i]);
        entry.rt_sum += parse_f64(fields[rt_i]);
    }

    println!("Modality,Trials,Accuracy,MeanReport,MeanTrace,MeanSelection,WMTransferRate,MeanRTms");

    let mut keys: Vec<String> = summaries.keys().cloned().collect();
    keys.sort();

    for key in keys {
        let s = summaries.get(&key).unwrap();
        let n = s.n as f64;
        println!(
            "{},{},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3}",
            key,
            s.n,
            s.correct_sum / n,
            s.report_sum / n,
            s.trace_sum / n,
            s.selection_sum / n,
            s.transfer_sum / n,
            s.rt_sum / n
        );
    }
}
