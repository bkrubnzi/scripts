extern crate rand;

use std::{thread, time, process};
use std::fs::File;
use std::io::prelude::*;
use rand::Rng;

fn main() -> std::io::Result<()> {
    let mut file = File::create("/var/run/runner.pid")?;
    let my_string = process::id().to_string();
    file.write_all(my_string.as_bytes())?;
    let mut i: u64 = 0;
    let mut my_mod: u64 = rand::thread_rng().gen_range(500,1000);
    loop {
        i +=1;
        let x: f64 = rand::thread_rng().gen_range(10000000.0,99999999.0);
        let y: f64 = rand::thread_rng().gen_range(10000000.0,99999999.0);
        let mut z: f64 = 0.0;
        if  x > y {
            z = x/y;
        }
        else {
            z = y/x;
        }

        if i % my_mod == 0 {
        i = 0;
        let my_delay = time::Duration::from_millis(rand::thread_rng().gen_range(1,100));
        my_mod = rand::thread_rng().gen_range(500,1000);
        //println!("{}",z.to_string());
        thread::sleep(my_delay);
        }
    }
    Ok(())
}
