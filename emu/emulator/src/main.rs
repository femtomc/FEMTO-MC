use std::io;
use std::io::prelude::*;
use std::fs::File;
use std::env;

mod emulator;
mod disassembler;

fn main() -> io::Result<()> {
    // Grab CL args: first argument is which file to assemble, second is name of output file.
    let args: Vec<String> = env::args().collect();

    // Instantiate the input file object.
    let mut i_file = File::open(&args[1])?;
    let mut contents = String::new();
    i_file.read_to_string(&mut contents)?;

    // Emulator.
    let in_vec: Vec<(i32, String)> = contents.split(|c| c == ';' || c == '\n').filter(
        |x| x.contains(":")).map(
        |x| (assembler::assembler::hex_to_num(&x[0..4]), 
            assembler::assembler::to_bin(&x[5..]).to_string())).collect();
    print!("In vec: {:?}\n", in_vec);

    let mem = emulator::Memory::new(in_vec);
    let mut comp = emulator::Computer::new(mem);
    comp.emulate(50, true);

    Ok(())
}

