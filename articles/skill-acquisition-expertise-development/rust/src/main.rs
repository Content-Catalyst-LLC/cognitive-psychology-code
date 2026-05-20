use std::{collections::HashMap, env, fs};

#[derive(Default)]
struct S { n: usize, acc: f64, err: f64, rt: f64, transfer: f64, auto: f64 }

fn f(x: &str) -> f64 { x.parse::<f64>().unwrap_or(f64::NAN) }

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 { eprintln!("Usage: cargo run --manifest-path rust/Cargo.toml -- data/skill_acquisition_trials.csv"); std::process::exit(1); }
    let text = fs::read_to_string(&args[1]).expect("read csv");
    let mut lines = text.lines();
    let header: Vec<&str> = lines.next().expect("header").split(',').collect();
    let idx = |name: &str| header.iter().position(|h| *h == name).expect(name);
    let level_i = idx("expertise_level"); let acc_i = idx("accuracy"); let err_i = idx("error_rate");
    let rt_i = idx("response_time_ms"); let tr_i = idx("transfer_score"); let au_i = idx("automaticity_score");
    let mut map: HashMap<String, S> = HashMap::new();
    for line in lines {
        if line.trim().is_empty() { continue; }
        let row: Vec<&str> = line.split(',').collect();
        let e = map.entry(row[level_i].to_string()).or_default();
        e.n += 1; e.acc += f(row[acc_i]); e.err += f(row[err_i]); e.rt += f(row[rt_i]); e.transfer += f(row[tr_i]); e.auto += f(row[au_i]);
    }
    println!("ExpertiseLevel,Trials,MeanAccuracy,MeanErrorRate,MeanResponseTimeMs,MeanTransfer,MeanAutomaticity");
    let mut keys: Vec<_> = map.keys().cloned().collect(); keys.sort();
    for k in keys {
        let s = map.get(&k).unwrap(); let n = s.n as f64;
        println!("{},{},{:.3},{:.3},{:.3},{:.3},{:.3}", k, s.n, s.acc/n, s.err/n, s.rt/n, s.transfer/n, s.auto/n);
    }
}
