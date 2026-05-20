use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    load_sum: f64,
    correct_sum: f64,
    accuracy_sum: f64,
    rt_sum: f64,
    span_sum: f64,
    updating_sum: f64,
    capacity_sum: f64,
    overload_sum: f64,
    cognitive_load_sum: f64,
    confidence_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/working_memory_trials.csv");
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
    let load_i = idx("load");
    let correct_i = idx("correct");
    let accuracy_i = idx("accuracy");
    let rt_i = idx("response_time_ms");
    let span_i = idx("span_score");
    let updating_i = idx("updating_score");
    let capacity_i = idx("capacity_estimate");
    let overload_i = idx("overload_probability");
    let cognitive_load_i = idx("cognitive_load");
    let confidence_i = idx("confidence");

    let mut summaries: HashMap<String, Summary> = HashMap::new();

    for line in lines {
        if line.trim().is_empty() {
            continue;
        }
        let fields: Vec<&str> = line.split(',').collect();
        let condition = fields[condition_i].to_string();
        let entry = summaries.entry(condition).or_default();
        entry.n += 1;
        entry.load_sum += parse_f64(fields[load_i]);
        entry.correct_sum += parse_f64(fields[correct_i]);
        entry.accuracy_sum += parse_f64(fields[accuracy_i]);
        entry.rt_sum += parse_f64(fields[rt_i]);
        entry.span_sum += parse_f64(fields[span_i]);
        entry.updating_sum += parse_f64(fields[updating_i]);
        entry.capacity_sum += parse_f64(fields[capacity_i]);
        entry.overload_sum += parse_f64(fields[overload_i]);
        entry.cognitive_load_sum += parse_f64(fields[cognitive_load_i]);
        entry.confidence_sum += parse_f64(fields[confidence_i]);
    }

    println!("Condition,Trials,MeanLoad,CorrectRate,MeanAccuracy,MeanRTms,MeanSpan,MeanUpdating,MeanCapacity,MeanOverloadProbability,MeanCognitiveLoad,MeanConfidence");

    let mut keys: Vec<String> = summaries.keys().cloned().collect();
    keys.sort();

    for key in keys {
        let s = summaries.get(&key).unwrap();
        let n = s.n as f64;
        println!(
            "{},{},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3}",
            key,
            s.n,
            s.load_sum / n,
            s.correct_sum / n,
            s.accuracy_sum / n,
            s.rt_sum / n,
            s.span_sum / n,
            s.updating_sum / n,
            s.capacity_sum / n,
            s.overload_sum / n,
            s.cognitive_load_sum / n,
            s.confidence_sum / n
        );
    }
}
