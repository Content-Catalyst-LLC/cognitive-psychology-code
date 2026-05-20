use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default, Debug)]
struct Summary {
    n: usize,
    mapping_sum: f64,
    transfer_sum: f64,
    structural_sum: f64,
    surface_sum: f64,
    quality_sum: f64,
    rt_sum: f64,
}

fn parse_f64(value: &str) -> f64 {
    value.parse::<f64>().unwrap_or(f64::NAN)
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/analogical_reasoning_trials.csv");
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
    let mapping_i = idx("mapping_accuracy");
    let transfer_i = idx("transfer_success");
    let structural_i = idx("structural_similarity");
    let surface_i = idx("surface_similarity");
    let quality_i = idx("inference_quality");
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
        entry.mapping_sum += parse_f64(fields[mapping_i]);
        entry.transfer_sum += parse_f64(fields[transfer_i]);
        entry.structural_sum += parse_f64(fields[structural_i]);
        entry.surface_sum += parse_f64(fields[surface_i]);
        entry.quality_sum += parse_f64(fields[quality_i]);
        entry.rt_sum += parse_f64(fields[rt_i]);
    }

    println!("Condition,Trials,MappingRate,TransferRate,MeanStructuralSimilarity,MeanSurfaceSimilarity,MeanInferenceQuality,MeanResponseTimeMs");

    let mut keys: Vec<String> = summaries.keys().cloned().collect();
    keys.sort();

    for key in keys {
        let s = summaries.get(&key).unwrap();
        let n = s.n as f64;
        println!(
            "{},{},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3}",
            key,
            s.n,
            s.mapping_sum / n,
            s.transfer_sum / n,
            s.structural_sum / n,
            s.surface_sum / n,
            s.quality_sum / n,
            s.rt_sum / n
        );
    }
}
