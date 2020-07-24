use std::io;
use std::io::prelude::*;
use std::fs::File;
use std::env;
use std::char;
use std::convert::TryFrom;

mod assembler;
mod disassembler;
mod lexer;
mod parser;
mod tests;

// Utility for pretty printing.
pub fn fixed_width_str(in_str: i32) -> String
{
    if in_str < 10
    {
        format!("{}     ", in_str)
    }
    else if in_str < 100
    {
        format!("{}    ", in_str)
    }
    else if in_str < 1000
    {
        format!("{}   ", in_str)
    }
    else if in_str < 10000
    {
        format!("{}  ", in_str)
    }
    else if in_str < 100000
    {
        format!("{} ", in_str)
    }

    else
    {
        format!("{}", in_str)
    }
}

fn main() -> io::Result<()> {
    // Grab CL args: first argument is which file to assemble, second is name of output file.
    let args: Vec<String> = env::args().collect();

    // Instantiate the input file object.
    let mut i_file = File::open(&args[1])?;
    let mut contents = String::new();
    i_file.read_to_string(&mut contents)?;

    // Assembler.
    let l = lexer::Lexer::new(contents.to_string());
    let p = parser::Parser::new(l);
    let mut asm = assembler::Assembler::new(p);

    // Constant header for all .mif files.
    let header = "DEPTH = 32768;\nWIDTH = 16;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n".to_string();

    // Assemble.
    let out = asm.eval();
    let split : Vec<String> = out.split(|c| c == '\n' || c == ' ').map(|s| s.to_string()).filter(|x| x != ":" && x.len() > 0 ).collect();
    let mut dis = String::new();
    for i in split.chunks(2)
    {
        let num = assembler::hex_to_num(&i[1][0..4]);
        let mut ascii : u8 = 0;
        if num < 127
        {
            let trans = u8::try_from(num).unwrap();
            ascii = trans;
        }

        dis.push_str(&format!("{} : {}   -->   {} :    {}   -->    Num: {:6} Ascii: {}\n", i[0], i[1], &fixed_width_str(assembler::hex_to_num(&i[0])), disassembler::disassemble(&assembler::to_bin(&i[1][0..4])), num, ascii as char));
    }

    // Write to output file.
    let mut o_file = File::create(&args[2])?;
    let path_split: Vec<String> = args[2].to_string().split('.').map(|s| s.to_string()).collect();
    let mut listings_path = path_split[0].to_string();
    listings_path.push_str(".listings");
    let mut listing_file = File::create(listings_path)?;

    listing_file.write_all(dis.as_bytes())?;

    o_file.write_all(header.as_bytes())?;
    o_file.write_all(out.as_bytes())?;
    o_file.write_all(b"END;")?;

    Ok(())
}
