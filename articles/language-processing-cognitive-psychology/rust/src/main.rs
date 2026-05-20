use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    comprehension_sum: f64,
    lexical_sum: f64,
    production_sum: f64,
    syntax_sum: f64,
    wm_sum: f64,
    reading_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/language_processing_trials.csv");
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
    let comprehension_i = idx("comprehension_accuracy");
    let lexical_i = idx("lexical_decision_accuracy");
    let production_i = idx("production_accuracy");
    let syntax_i = idx("syntactic_complexity");
    let wm_i = idx("working_memory_load");
    let reading_i = idx("reading_time_ms");

    let mut summaries: HashMap<String, Summary> = HashMap::new();

    for line in lines {
        if line.trim().is_empty() {
            continue;
        }

        let fields: Vec<&str> = line.split(',').collect();
        let condition = fields[condition_i].to_string();

        let entry = summaries.entry(condition).or_default();
        entry.n += 1;
        entry.comprehension_sum += parse_f64(fields[comprehension_i]);
        entry.lexical_sum += parse_f64(fields[lexical_i]);
        entry.production_sum += parse_f64(fields[production_i]);
        entry.syntax_sum += parse_f64(fields[syntax_i]);
        entry.wm_sum += parse_f64(fields[wm_i]);
        entry.reading_sum += parse_f64(fields[reading_i]);
    }

    println!("Condition,Trials,ComprehensionRate,LexicalDecisionRate,ProductionRate,MeanSyntax,MeanWMLoad,MeanReadingTimeMs");

    let mut keys: Vec<String> = summaries.keys().cloned().collect();
    keys.sort();

    for key in keys {
        let s = summaries.get(&key).unwrap();
        let n = s.n as f64;
        println!(
            "{},{},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3}",
            key,
            s.n,
            s.comprehension_sum / n,
            s.lexical_sum / n,
            s.production_sum / n,
            s.syntax_sum / n,
            s.wm_sum / n,
            s.reading_sum / n
        );
    }
}
