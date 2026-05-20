use std::collections::HashMap;
use std::env;
use std::fs;

#[derive(Default)]
struct Summary {
    n: usize, correct: f64, recall: f64, old: f64, source: f64,
    confidence: f64, fluency: f64, rt: f64, transfer: f64, strength: f64, forgetting: f64,
}

fn parse(v: &str) -> f64 { v.parse::<f64>().unwrap_or(f64::NAN) }

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/memory_trials.csv");
        std::process::exit(1);
    }
    let content = fs::read_to_string(&args[1]).expect("Could not read CSV");
    let mut lines = content.lines();
    let headers: Vec<&str> = lines.next().expect("Missing header").split(',').collect();
    let idx = |name: &str| -> usize { headers.iter().position(|h| *h == name).unwrap_or_else(|| panic!("Missing {}", name)) };

    let c_i = idx("condition"); let correct_i = idx("correct"); let recall_i = idx("recall_accuracy");
    let old_i = idx("response_old"); let source_i = idx("source_correct"); let conf_i = idx("recognition_confidence");
    let flu_i = idx("retrieval_fluency"); let rt_i = idx("response_time_ms"); let tr_i = idx("learning_transfer");
    let str_i = idx("retention_strength"); let f_i = idx("forgetting_rate");

    let mut map: HashMap<String, Summary> = HashMap::new();
    for line in lines {
        if line.trim().is_empty() { continue; }
        let f: Vec<&str> = line.split(',').collect();
        let e = map.entry(f[c_i].to_string()).or_default();
        e.n += 1; e.correct += parse(f[correct_i]); e.recall += parse(f[recall_i]); e.old += parse(f[old_i]);
        e.source += parse(f[source_i]); e.confidence += parse(f[conf_i]); e.fluency += parse(f[flu_i]);
        e.rt += parse(f[rt_i]); e.transfer += parse(f[tr_i]); e.strength += parse(f[str_i]); e.forgetting += parse(f[f_i]);
    }
    println!("Condition,Trials,CorrectRate,MeanRecallAccuracy,OldResponseRate,SourceCorrectRate,MeanConfidence,MeanFluency,MeanRTms,MeanTransfer,MeanRetentionStrength,MeanForgettingRate");
    let mut keys: Vec<String> = map.keys().cloned().collect(); keys.sort();
    for k in keys {
        let s = map.get(&k).unwrap(); let n = s.n as f64;
        println!("{},{},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3},{:.3}",
            k, s.n, s.correct/n, s.recall/n, s.old/n, s.source/n, s.confidence/n, s.fluency/n,
            s.rt/n, s.transfer/n, s.strength/n, s.forgetting/n);
    }
}
