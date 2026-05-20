use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    correct_sum: f64,
    yes_sum: f64,
    rt_sum: f64,
    confidence_sum: f64,
    lapse_sum: f64,
    vigilance_sum: f64,
    distractor_sum: f64,
    executive_sum: f64,
    divided_cost_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/attention_trials.csv");
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
    let rt_i = idx("rt");
    let confidence_i = idx("confidence");
    let lapse_i = idx("lapse_probability");
    let vigilance_i = idx("vigilance_state");
    let distractor_i = idx("distractor_load");
    let executive_i = idx("executive_load");
    let divided_i = idx("divided_attention_cost");

    let mut summaries: HashMap<String, Summary> = HashMap::new();

    for line in lines {
        if line.trim().is_empty() {
            continue;
        }
        let fields: Vec<&str> = line.split(',').collect();
        let condition = fields[condition_i].to_string();
        let entry = summaries.entry(condition).or_default();
        entry.n += 1;
        entry.correct_sum += parse_f64(fields[correct_i]);
        entry.yes_sum += parse_f64(fields[yes_i]);
        entry.rt_sum += parse_f64(fields[rt_i]);
        entry.confidence_sum += parse_f64(fields[confidence_i]);
        entry.lapse_sum += parse_f64(fields[lapse_i]);
        entry.vigilance_sum += parse_f64(fields[vigilance_i]);
        entry.distractor_sum += parse_f64(fields[distractor_i]);
        entry.executive_sum += parse_f64(fields[executive_i]);
        entry.divided_cost_sum += parse_f64(fields[divided_i]);
    }

    println!("Condition,Trials,CorrectRate,YesRate,MeanRT,MeanConfidence,MeanLapseProbability,MeanVigilanceState,MeanDistractorLoad,MeanExecutiveLoad,MeanDividedAttentionCost");

    let mut keys: Vec<String> = summaries.keys().cloned().collect();
    keys.sort();

    for key in keys {
        let s = summaries.get(&key).unwrap();
        let n = s.n as f64;
        println!(
            "{},{},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3}",
            key,
            s.n,
            s.correct_sum / n,
            s.yes_sum / n,
            s.rt_sum / n,
            s.confidence_sum / n,
            s.lapse_sum / n,
            s.vigilance_sum / n,
            s.distractor_sum / n,
            s.executive_sum / n,
            s.divided_cost_sum / n
        );
    }
}
