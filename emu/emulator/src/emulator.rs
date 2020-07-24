use std::usize;
use std::str;
use std::io;
use std::convert::TryFrom;
use std::fmt::{Display, Formatter, Error};
use arrayvec::ArrayString;
use crate::disassembler;

use assembler;
use assembler::lexer;
use assembler::assembler::{to_bin, bin_to_num};

use std::{thread, time};

#[derive(Clone)]
pub struct Register
{
    contents: i32
}

pub struct Memory
{
    contents: Vec<ArrayString<[u8; 8]>>
}

impl Memory 
{
    pub fn new(init: Vec<(i32, String)>) -> Memory
    {
        let mut mem = vec![ArrayString::<[u8; 8]>::new(); 2*65535];
        for i in init.iter()
        {
            let mut byte_1 = i.1.as_str().to_string();
            let byte_2 = byte_1.split_off(8);
            let ind = usize::try_from(i.0).unwrap_or(0);
            mem[2*ind + 1] = ArrayString::<[u8; 8]>::from(&byte_1).unwrap();
            mem[2*ind] = ArrayString::<[u8; 8]>::from(&byte_2).unwrap();
        }
        return Memory { contents: mem }
    }

   pub fn get(&self, index: usize) -> Option<String>
   {
       return Some(self.contents[index].as_str().to_string())
   }

   pub fn set(&mut self, index: usize, new_contents: &str) -> ()
   {
       self.contents[index] = ArrayString::<[u8; 8]>::from(new_contents).unwrap();
   }
}

pub struct Computer
{
    regs:Vec<Register>,
    memory: Memory,
    pc: Register,
    compressed_display: bool,
}

impl Computer
{
    pub fn new(mem: Memory) -> Computer
    {
        let regs = vec![Register { contents:  0}; 16];
        return Computer { regs: regs, memory: mem, pc: Register { contents: 0 } , compressed_display: false }
    }

    // Gets the current instruction from memory.
    pub fn get_curr_instr(&self) -> String
    {
        let pc_ind = usize::try_from(self.pc.contents).unwrap_or(0);
        let high_order = self.memory.get(pc_ind + 1).unwrap();
        let low_order = self.memory.get(pc_ind).unwrap();
        let instr = format!("{}{}", high_order, low_order);
        return instr.to_string()
    }

    // Core of the emulator. Takes a line and updates the memory and registers state.
    pub fn run_curr_instr(&mut self) -> ()
    {
        let disassembled_line = disassembler::disassemble(&self.get_curr_instr());
        self.pc.contents += 2;

        // This is the virtual machine semantics for each of the instructions. At this point, all
        // the symbols and memory have been resolved and allocated.
        match disassembled_line.op
        {
            lexer::InstructionType::ADD => 
            {
                let num_0 = self.regs[disassembled_line.operands[0].id].contents;
                let num_1 = self.regs[disassembled_line.operands[1].id].contents;
                let f_op = format!("{:04b}", disassembled_line.immed);
                let res = match f_op.as_str()
                {
                    "0000" => num_0 + num_1,
                    "0011" => -num_0 + num_1,
                    "1011" => num_0 - num_1,
                    _ => panic!("Error: immediate {} in -> add R{}, R{}, {} is illegal.\n", f_op, disassembled_line.operands[0].id, disassembled_line.operands[1].id, f_op),
                };
                self.regs[disassembled_line.operands[0].id].contents = res;
            },

            lexer::InstructionType::ADDI => 
            {
                self.regs[disassembled_line.operands[0].id].contents += disassembled_line.immed;
            },

            lexer::InstructionType::MEM => 
            {
                let f_op = format!("{:04b}", disassembled_line.immed);
                match f_op.as_str()
                {
                    "0000" => {
                        let ind = usize::try_from(self.regs[disassembled_line.operands[1].id].contents * 2).unwrap();
                        let inp = match ind
                        {
                             65280 => {
                                 format!("1111111111111111")
                            }

                             65284 => {
                                let mut input = String::new();
                                print!("\nInput:\n");
                                io::stdin().read_line(&mut input).unwrap();
                                format!("{:016b}", input.as_bytes()[0])
                            }

                             65288 => {
                                let mut input = String::new();
                                print!("\nInput:\n");
                                io::stdin().read_line(&mut input).unwrap();
                                format!("{:016b}", input.as_bytes()[0])
                            }

                            _ => {
                                let low_order = self.memory.get(ind).unwrap();
                                let mut high_order = self.memory.get(ind + 1).unwrap();
                                high_order.push_str(&low_order);
                                high_order
                            }
                        };

                        self.regs[disassembled_line.operands[0].id].contents = bin_to_num(&inp);
                    },

                    "0001" => {
                        let mut mem_contents = format!("{:016b}", self.regs[disassembled_line.operands[0].id].contents);
                        let ind = usize::try_from(self.regs[disassembled_line.operands[1].id].contents).unwrap();
                        let byte_2 = mem_contents.split_off(8);
                        self.memory.set(2*ind + 1, &mem_contents);
                        self.memory.set(2*ind, &byte_2);
                    },

                    "1001" => {
                        let ind = disassembled_line.operands[1].id * 2;
                        let mem_contents = to_bin(&self.memory.get(ind).unwrap());
                        self.regs[disassembled_line.operands[0].id].contents = bin_to_num(&mem_contents);
                    },

                    "0101" => {
                        let mem_contents = to_bin(format!("{:016b}", self.regs[disassembled_line.operands[0].id].contents).as_str());
                        self.memory.set(usize::try_from(self.regs[disassembled_line.operands[0].id].contents).unwrap(), &mem_contents);
                    },

                    _ => panic!("In emulator - instruction MEM: function bits are illegal."),
                }
            },

            lexer::InstructionType::LOG => 
            {
                let operand_0 = self.regs[disassembled_line.operands[0].id].contents;
                let operand_1 = self.regs[disassembled_line.operands[1].id].contents;
                let f_op = format!("{:04b}", disassembled_line.immed);
                let res = {
                    let f_op_iter = f_op.as_bytes();
                    let mut res = operand_0 & operand_1;
                    if f_op_iter[0] == b'1'
                    {
                        res = operand_0 | operand_1;
                    }
                    if f_op_iter[1] == b'1'
                    {
                        res = operand_0 ^ operand_1;
                    }
                    if f_op_iter[2] == b'1'
                    {
                        res = !(operand_0 & operand_1);
                    }
                    if f_op_iter[3] == b'1'
                    {
                        res = !res;
                    }
                    if res < 0
                    {
                        res = 65536 + res
                    }
                    res
                };
                self.regs[disassembled_line.operands[0].id].contents = res;
            },

            lexer::InstructionType::BEQ => 
            {
                let operand_0 = self.regs[disassembled_line.operands[0].id].contents;
                let operand_1 = self.regs[disassembled_line.operands[1].id].contents;
                let immed = disassembled_line.immed;
                if operand_1 == immed
                {
                    self.pc.contents = operand_0
                }
            },

            lexer::InstructionType::JUMP => 
            {
                let curr_pc = self.pc.contents;
                let target_loc = self.regs[disassembled_line.operands[1].id].contents;
                self.regs[disassembled_line.operands[0].id].contents = curr_pc;
                self.pc.contents = target_loc
            },

            lexer::InstructionType::LUI => 
            {
                self.regs[disassembled_line.operands[0].id].contents = disassembled_line.immed << 8;
            },

            lexer::InstructionType::SHIFTL => 
            {
                let operand_0 = self.regs[disassembled_line.operands[0].id].contents;
                let operand_1 = self.regs[disassembled_line.operands[1].id].contents;
                let shift = {
                    let mut new_str = format!("{:016b}", operand_0);
                    let (fst, snd) = new_str.split_at_mut(usize::try_from(operand_1).unwrap());
                    let mut new = snd.to_string();
                    new.push_str(fst);
                    bin_to_num(&new)
                };
                self.regs[disassembled_line.operands[0].id].contents = shift
            },

            lexer::InstructionType::SHIFTR => 
            {
                let operand_0 = self.regs[disassembled_line.operands[0].id].contents;
                let operand_1 = self.regs[disassembled_line.operands[1].id].contents;
                self.regs[disassembled_line.operands[0].id].contents = {
                    let mut new_str = format!("{:016b}", operand_0);
                    let (fst, snd) = new_str.split_at_mut(16 - usize::try_from(operand_1).unwrap());
                    let mut new = snd.to_string();
                    new.push_str(fst);
                    bin_to_num(&new)
                }
            },

            _ => panic!("Error: illegal instruction during operation.")
        }
    }

    // Runs the emulation in a loop or until a panic! occurs.
    pub fn emulate(&mut self, sleep_time: u64, compressed: bool) -> ()
    {
        self.compressed_display = compressed;
        let sleep_time = time::Duration::from_millis(sleep_time);
        print!("{}", self);
        loop {
            self.run_curr_instr();
            print!("{}", self);
            thread::sleep(sleep_time);
        }
    }
}

// Utility for pretty printing the state of the computer.
pub fn fixed_width_str(in_str: usize) -> String
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

// Pretty printer.
impl Display for Computer {
    fn fmt(&self, f: &mut Formatter) -> Result<(), Error> {
        let mut comma_separated = String::new();
        let counter = 0;
        let mut reg_counter = 0;
        let num_regs = self.regs.len();
        comma_separated.push_str("                        FEMTO - MC\n");
        comma_separated.push_str("/----------------------------------------------------------\\\n|          Memory                           Registers      |\n|                                                          |\n");
        if !self.compressed_display {
            comma_separated.push_str("| Byte                Contents                 Word        |\n|                                                          |\n");
            for loc in self.memory.contents.iter().enumerate().filter(|x| !(x.1.is_empty()))
            {
                if loc.0  < num_regs
                {
                    comma_separated.push_str(&format!("|  {}     ->     {:?}        |       {}      |\n", fixed_width_str(loc.0 + counter), loc.1, fixed_width_str(usize::try_from(self.regs[loc.0 + counter].contents).unwrap())).to_string());
                    reg_counter += 1;
                }

                else
                {
                    comma_separated.push_str(&format!("|  {}     ->     {:?}        |                   |\n", fixed_width_str(loc.0 + counter), loc.1).to_string());
                }
            }

            while reg_counter < num_regs
            {
                comma_separated.push_str(&format!("|                                      |       {}      |\n", fixed_width_str(usize::try_from(self.regs[reg_counter].contents).unwrap())).to_string());
                reg_counter += 1;
            }

            comma_separated.push_str("|                                                          |\n\\----------------------------------------------------------/\n");
        }

        comma_separated.push_str(&format!("|\n| PC (Byte)                  :          {}\n", self.pc.contents).to_string());
        comma_separated.push_str(&format!("| PC (Word)                  :          {}\n", self.pc.contents/2).to_string());
        comma_separated.push_str(&format!("| Current instruction        :          {}                    \n", self.get_curr_instr()).to_string());
        let dis = disassembler::disassemble(&self.get_curr_instr());
        comma_separated.push_str(&format!("| Disassembled               :          {}             \n", dis).to_string());
        let mut byte_1 = self.memory.get(65285).unwrap_or("00000000".to_string());
        let byte_2 = self.memory.get(65284).unwrap_or("00000000".to_string());
        byte_1.push_str(&byte_2);
        let num = bin_to_num(&byte_1);
        comma_separated.push_str(&format!("| Out buffer                 :          {}             \n", byte_1));
        comma_separated.push_str(&format!("| Number                     :          {}             \n", num));
        comma_separated.push_str(&format!("| 2s                         :          {}             \n", -65536 + num));
        if num < 127
        {
            comma_separated.push_str(&format!("| ASCII                      :          {}\n", str::from_utf8(&vec![u8::try_from(num).unwrap()]).unwrap()));
        }
        else
        {
            comma_separated.push_str(&format!("| ASCII                      :          {}             \n", "ILLEGAL"));
        }
        comma_separated.push_str(&format!("|\n| Registers (compressed)     0       =>  {}             \n", self.regs[0].contents));
        for i in 1..16
        {
            comma_separated.push_str(&format!("|                            {}  =>  {}      \n", fixed_width_str(usize::try_from(i).unwrap()).to_string(), self.regs[i].contents).to_string());
        }
        comma_separated.push_str("\\----------------------------------------------------------/\n");
        write!(f, "\n{}\x1B[2J", comma_separated)
            //write!(f, "\n{}", comma_separated)
    }
}

