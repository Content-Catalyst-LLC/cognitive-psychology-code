use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    burden_sum: f64,
    quality_sum: f64,
    satisficing_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/organizational_decision_trials.csv");
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
    let info_i = idx("info_load");
    let uncertainty_i = idx("uncertainty_level");
    let coordination_i = idx("coordination_load");
    let pressure_i = idx("institutional_pressure");
    let delay_i = idx("feedback_delay");
    let safety_i = idx("psychological_safety");
    let dissent_i = idx("dissent_present");
    let automation_i = idx("automation_reliance");
    let quality_i = idx("decision_quality");
    let sat_i = idx("chose_satisficing");

    let mut summaries: HashMap<String, Summary> = HashMap::new();

    for line in lines {
        if line.trim().is_empty() {
            continue;
        }

        let fields: Vec<&str> = line.split(',').collect();
        let condition = fields[condition_i].to_string();

        let burden = parse_f64(fields[info_i])
            + parse_f64(fields[uncertainty_i])
            + parse_f64(fields[coordination_i])
            + parse_f64(fields[pressure_i])
            + 0.5 * parse_f64(fields[delay_i])
            + 0.25 * parse_f64(fields[automation_i])
            - 0.55 * parse_f64(fields[safety_i])
            - 0.9 * parse_f64(fields[dissent_i]);

        let quality = parse_f64(fields[quality_i]);
        let satisficing = parse_f64(fields[sat_i]);

        let entry = summaries.entry(condition).or_default();
        entry.n += 1;
        entry.burden_sum += burden;
        entry.quality_sum += quality;
        entry.satisficing_sum += satisficing;
    }

    println!("Condition,Trials,MeanBurden,MeanQuality,SatisficingRate");

    let mut keys: Vec<String> = summaries.keys().cloned().collect();
    keys.sort();

    for key in keys {
        let s = summaries.get(&key).unwrap();
        let n = s.n as f64;
        println!(
            "{},{},{:.3},{:.3},{:.3}",
            key,
            s.n,
            s.burden_sum / n,
            s.quality_sum / n,
            s.satisficing_sum / n
        );
    }
}
