use std::usize;
use std::convert::TryFrom;

use assembler;
use assembler::lexer;
use assembler::assembler::bin_to_num;

use std::fmt::{Display, Formatter, Error};

pub struct RegisterReference {
    pub id: usize,
}

pub struct DisassembledLine
{
    pub op: lexer::InstructionType,
    pub operands: Vec<RegisterReference>,
    pub immed: i32,
}

impl Display for DisassembledLine
{
    fn fmt(&self, f: &mut Formatter) -> Result<(), Error>
    {
        let mut pvec = Vec::new();
        let mut pstring = String::new();
        let lit = match self.op
        {
            lexer::InstructionType::ADD => "add     ",
            lexer::InstructionType::LOG => "log     ", 
            lexer::InstructionType::MEM => "mem     ", 
            lexer::InstructionType::BEQ => "beq     ",
            lexer::InstructionType::JUMP => "jump    ",
            lexer::InstructionType::SHIFTL => "shiftl  ",
            lexer::InstructionType::SHIFTR => "shiftr  ",
            lexer::InstructionType::LUI => "lui     ",
            lexer::InstructionType::ADDI => "addi    ",
            lexer::InstructionType::ILLEGAL_INSTRUCTION => "ILLEGAL ",
        }.to_string();

        pvec.push(format!("{}", self.immed).as_str().to_string());

        for i in self.operands.iter().rev()
        {
            let operand = match i
            {
                RegisterReference { id }=>  format!("R{}, ", id),
            };
            pvec.push(operand.to_string());
        }


        pvec.push(lit);
        for i in pvec.iter().rev()
        {
            pstring.push_str(i)
        }

        write!(f, "{}", pstring)
    }
}


pub fn disassemble(input: &str) -> DisassembledLine
{
    // Parse rhs into Nodes.
    let mut byte_1 = input.to_string();
    let mut byte_2 = byte_1.split_off(4);
    let mut byte_3 = byte_2.split_off(4);
    let byte_4 = byte_3.split_off(4);

    let op = match byte_1.as_str()
    {
        "1000" => lexer::InstructionType::ADD,  
        "1001" => lexer::InstructionType::LOG,  
        "0001" => lexer::InstructionType::MEM,  
        "0010" => lexer::InstructionType::BEQ,  
        "0011" => lexer::InstructionType::JUMP,
        "0100" => lexer::InstructionType::SHIFTL,
        "0101" => lexer::InstructionType::SHIFTR,
        "0000" => lexer::InstructionType::LUI,
        "1010" => lexer::InstructionType::ADDI,
        _ => lexer::InstructionType::ILLEGAL_INSTRUCTION,
    };

    let reg_1 = RegisterReference{ id : usize::try_from(bin_to_num(byte_2.as_str())).unwrap() };
    let reg_2 = RegisterReference{ id : usize::try_from(bin_to_num(byte_3.as_str())).unwrap() };

    // Disassembles correctly for RI-type instructions (ADDI and LUI)
    let dis = match op
    {
        lexer::InstructionType::ADDI => {
            let mut immed = String::new();
            immed.push_str(&byte_3);
            immed.push_str(&byte_4);
            DisassembledLine { op : op, operands : vec![reg_1], immed: bin_to_num(&immed) }
        },

        lexer::InstructionType::LUI => {
            let mut immed = String::new();
            immed.push_str(&byte_3);
            immed.push_str(&byte_4);
            DisassembledLine { op : op, operands : vec![reg_1], immed: bin_to_num(&immed) }
        }

        _  => DisassembledLine { op : op, operands : vec![reg_1, reg_2], immed: bin_to_num(&byte_4) }
    };

    return dis
}
