#![allow(dead_code, non_snake_case)]
use std::collections::HashMap;
use std::fmt::{Debug, Error, Formatter};

use std::usize;
use std::convert::TryFrom;

use crate::lexer;
use crate::lexer::Token;

use crate::parser::Parser;
use crate::parser::Node::{
    self,
    DirectiveExpr,
    LabelledExpr,
    InstructionExpr,
};


// Utility - takes in a string representing a binary number and returns a hexadecimal version.
// Assumes that the binary representation is 2 bytes long (i.e. 16 bits).
pub fn to_hex(b: &str) -> String
{
    let mut ret = 0;
    let base: i32 = 2;
    let mut accumulator = 1;
    for dig in b.as_bytes().iter().rev()
    {
        match dig {
            49 => {
                ret += base.pow(accumulator-1);
            }

            _ => {
                ret += 0
            }
        }
        accumulator += 1;
    }
    return format!("{:04x}", ret)
}

// Utility - takes in a string representing a hexadecimal number and returns a binary version.
// Assumes that the hexadecimal representation is 2 bytes long (i.e. 16 bits).
pub fn to_bin(h: &str) -> String
{
    let mut ret = 0;
    let base: i32 = 16;
    let mut accumulator = 1;
    for dig in h.as_bytes().iter().rev()
    {
        let v = match dig {
            b'0' => 0,
            b'1' => 1,
            b'2' => 2,
            b'3' => 3,
            b'4' => 4,
            b'5' => 5,
            b'6' => 6,
            b'7' => 7,
            b'8' => 8,
            b'9' => 9,
            b'a' => 10,
            b'b' => 11,
            b'c' => 12,
            b'd' => 13,
            b'e' => 14,
            b'f' => 15,
            _ => 0,
        };
        ret += v*base.pow(accumulator - 1);
        accumulator += 1
    }
    return format!("{:016b}", ret)
}

pub fn hex_to_num(h: &str) -> i32
{
    let mut ret = 0;
    let base: i32 = 16;
    let mut accumulator = 1;
    for dig in h.as_bytes().iter().rev()
    {
        let v = match dig {
            b'0' => 0,
            b'1' => 1,
            b'2' => 2,
            b'3' => 3,
            b'4' => 4,
            b'5' => 5,
            b'6' => 6,
            b'7' => 7,
            b'8' => 8,
            b'9' => 9,
            b'a' => 10,
            b'b' => 11,
            b'c' => 12,
            b'd' => 13,
            b'e' => 14,
            b'f' => 15,
            _ => 0,
        };
        ret += v*base.pow(accumulator - 1);
        accumulator += 1
    }
    return ret
}

pub fn bin_to_num(b: &str) -> i32
{
    let mut ret = 0;
    let base: i32 = 2;
    let mut accumulator = 1;
    for dig in b.as_bytes().iter().rev()
    {
        match dig {
            49 => {
                ret += base.pow(accumulator-1);
            }

            _ => {
                ret += 0
            }
        }
        accumulator += 1;
    }
    return ret
}

// Represents line of assembly code. Holds an AST node and a location marker, both are used during
// decoding.
pub struct Line
{
    loc: usize,
    expr: Node,
}

impl Debug for Line {
    fn fmt(&self, f: &mut Formatter) -> Result<(), Error> 
    {
        write!(f, "\n(Word) {} : \n{:?}\n", self.loc, self.expr)
    }
}

// The assembler proper - contains a Parser, a symbol table (as a HashMap) and a memory counter.
#[derive(Debug)]
pub struct Assembler
{
    p: Parser,
    st: HashMap<String, usize>,
    memory_counter: usize,
}

impl Assembler {

    pub fn new(p: Parser) -> Assembler
    {
        let asm = Assembler { p: p , st: HashMap::<String, usize>::new() , memory_counter: 0 };
        return asm
    }

    pub fn create_symbol(&mut self, sym: &String, mem: usize) -> ()
    {
        self.st.insert(sym.to_string(), mem);
    }

    // This directly decodes tokens in an Expr.
    pub fn decode_token(&mut self, token: &Token) -> String
    {
        match &token.tt
        {
            lexer::TokenType::INSTRUCTION(x) => match x
            {
                lexer::InstructionType::ADD => "1000",
                lexer::InstructionType::LOG => "1001",
                lexer::InstructionType::MEM => "0001",
                lexer::InstructionType::BEQ => "0010",
                lexer::InstructionType::JUMP => "0011",
                lexer::InstructionType::SHIFTL => "0100",
                lexer::InstructionType::SHIFTR => "0101",
                lexer::InstructionType::LUI => "0000",
                lexer::InstructionType::ADDI => "1010",
                _ => "0000",
            }.to_string(),

            lexer::TokenType::DIRECTIVE(lexer::DirectiveType::LABEL) => {
                match self.st.get(&token.lit) {
                    Some(lookup) => {
                        let out = format!("{:016b}", lookup);
                        out[8..16].to_string()
                    },
                    None => format!("{:08b}", 0),
                }.to_string()
            }

            lexer::TokenType::REGISTER => {
                format!("{:04b}", token.lit.parse::<u32>().unwrap()).to_string()
            },

            lexer::TokenType::INT { sign } => {
                if *sign
                {
                    let lit = token.lit.parse::<i16>().unwrap();
                    let out = format!("{:08b}", -1 * lit);
                    out
                }
                else
                {
                    format!("{:08b}", token.lit.parse::<i16>().unwrap())
                }
            },

            lexer::TokenType::STRING => {
                let bytes = token.lit.as_bytes();
                let mut bin_str = String::new();
                if bytes.len() > 1
                {
                    panic!("String input is larger than 2 bytes!")
                }
                else
                {
                    bin_str.push_str(&format!("{:016b}", &bytes[0]));
                }
                return bin_str
            }

            _ => {
                "0000".to_string()
            }
        }
    }

    // This first pass has to do a bit of analysis.
    // In particular, for any allocation directives, the assembler has to compute the correct
    // location for the following word in memory.
    // Simultaneously, this pass inserts labels into the symbol table.
    pub fn create_memory(&mut self) -> Vec<Line>
    {
        let mut layout = Vec::<Line>::new();
        let program = self.p.parse_program();

        // First pass - create symbol table.
        for expr in program.exprs.iter()
        {
            match expr
            {
                LabelledExpr { label, expr } => {
                    match &**expr {
                        DirectiveExpr { directive: _ , args } => {
                            let loc = usize::try_from(args[0].lit.parse::<i32>().unwrap_or(0)).unwrap();
                            self.create_symbol(&label.lit, loc);
                            if loc <= self.memory_counter
                            {
                                self.memory_counter += 1
                            }
                        },

                        _ => {
                            self.create_symbol(&label.lit, 2*self.memory_counter);
                            self.memory_counter += 1
                        },
                    }
                },

                _ => {
                    self.memory_counter += 1
                }
            }
        }

        self.memory_counter = 0;
        let mut st = HashMap::<String, usize>::new();

        // Second pass - resolve pseudo-instruction requirements.
        for expr in program.exprs.iter()
        {
            match expr
            {
                LabelledExpr { label, expr } => {
                    match &**expr {
                        DirectiveExpr { directive: _ , args } => {
                            let loc = usize::try_from(args[0].lit.parse::<i32>().unwrap_or(0)).unwrap();
                            st.insert(label.lit.to_string(), loc);
                            if loc <= self.memory_counter
                            {
                                self.memory_counter += 1
                            }
                            layout.push( Line { loc: loc, expr: *expr.clone() });
                        },

                        _ => {
                            st.insert(label.lit.to_string(), 2*self.memory_counter);
                            layout.push(Line { loc: self.memory_counter, expr: *expr.clone() });
                            self.memory_counter += 1
                        },
                    }
                },

                InstructionExpr { instruction, operands } => {
                    let op_code = self.decode_token(instruction);
                    if op_code == "1010"
                    {
                        match operands[1].tt
                        {
                            lexer::TokenType::DIRECTIVE(lexer::DirectiveType::LABEL) => {
                                let fmt_str = match self.st.get(&operands[1].lit) {
                                    Some(lookup) => i32::try_from(*lookup).unwrap(),
                                    None => 0,
                                };
                                if fmt_str > 255
                                {
                                    let all_bits = format!("{:016b}", fmt_str);
                                    let new_line = Line { 
                                        loc: self.memory_counter, 
                                        expr: InstructionExpr { 
                                            instruction: Token { tt: lexer::TokenType::INSTRUCTION(lexer::InstructionType::LUI), lit: "lui".to_string() }, 
                                            operands: vec![operands[0].clone(), Token { 
                                                tt: lexer::TokenType::INT { sign : false },
                                                lit: bin_to_num(&format!("00000000{}", &all_bits[0..8])).to_string(),
                                            }]
                                        }
                                    };

                                    layout.push(new_line);
                                    self.memory_counter += 1;
                                    let transformed_old = Line { 
                                        loc: self.memory_counter, 
                                        expr: InstructionExpr { 
                                            instruction: Token { tt: lexer::TokenType::INSTRUCTION(lexer::InstructionType::ADDI), lit: "addi".to_string() }, 
                                            operands: vec![operands[0].clone(), Token { 
                                                tt: operands[1].tt.clone(),
                                                lit: operands[1].lit.clone(),
                                            }]
                                        }
                                    };
                                    

                                    layout.push(transformed_old);
                                    self.memory_counter += 1;
                                }

                                else
                                {
                                    layout.push(Line { loc: self.memory_counter, expr: expr.clone()});
                                    self.memory_counter += 1;
                                }
                            },

                            _ => {
                                layout.push(Line { 
                                    loc:self.memory_counter,
                                    expr: expr.clone()});
                                self.memory_counter += 1
                            }
                        }
                    }

                    else
                    {
                        layout.push(Line { loc: self.memory_counter, expr: expr.clone() });
                        self.memory_counter += 1;
                    }
                },
                _ => {
                    layout.push(Line{ loc: self.memory_counter, expr: expr.clone() });
                    self.memory_counter += 1;
                }
            }
        }

        self.st = st;
        return layout
    }

    // This decodes directives - these affect the assembler directly, so this returns a "raw"
    // String which should be directly output to file. If you look at the calling function
    // (decode_line), other decode expressions return strings which are formatted there. Because
    // decoding a directive will typically affect the memory counter significantly, string
    // formatting is done in the body of decode_directive.
    pub fn decode_directive(&mut self, loc: usize, directive: &Token, args: &Vec<Token>) -> String
    {
        let mut out = String::new();
        match &directive.tt
        {
            lexer::TokenType::DIRECTIVE(lexer::DirectiveType::ASCIIZ) => 
            {
                let mut ind = loc;
                for dig in args[1].lit.as_bytes().iter()
                {
                    out.push_str(&format!("{:04x} : {};\n", ind, to_hex(&format!("{:016b}", dig))));
                    ind += 1;
                }
                out.push_str(&format!("{:04x} : {};\n", ind, to_hex(&format!("{:016b}", b'\0'))));
                return out.to_string()
            },

            lexer::TokenType::DIRECTIVE(lexer::DirectiveType::LABEL) => 
            {
                return format!("{} : {};", loc, "0000").to_string()
            }

            lexer::TokenType::DIRECTIVE(lexer::DirectiveType::WORD) =>
            {
                let lit = match &args[1].tt
                {
                    lexer::TokenType::INT { sign: _ } => format!("{:016b}", bin_to_num(&self.decode_token(&args[1]))),
                    _ => self.decode_token(&args[1]),
                };

                let hex = to_hex(&format!("{:016b}", bin_to_num(&lit)));
                out.push_str(&format!("{:04x} : {};\n", loc, hex));
                return out.to_string()
            },

            lexer::TokenType::DIRECTIVE(lexer::DirectiveType::CONST) =>
            {
                let lit = &args[0].lit;
                let dig = lit.parse::<i32>().unwrap();
                out.push_str(&format!("{:04x} : {};\n", loc, to_hex(&format!("{:016b}", dig))));
                return out.to_string()
            },

            _ => {
                "0000".to_string()
            }
        }
    }

    // Main workhorse of the assembler - iterates over lines and decodes them. This function
    // assumes that the assembler has constructed a symbol table using create_memory.
    pub fn decode_line(&mut self, loc: usize, expr: &Node) -> String
    {
        let mut working = String::new();
        match expr
        {
            // Also handles addi where the immediate is larger than represented by 8 bits.
            InstructionExpr { instruction, operands } =>
            {
                let op_code = self.decode_token(instruction);
                working.push_str(&op_code);
                for (i, operand) in operands.iter().enumerate()
                {
                    let mut decoding = self.decode_token(operand);
                    if i == 2
                    {
                        decoding = decoding[4..8].to_string();
                    }
                    working.push_str(&decoding);
                }
                return format!("{:04x} : {};\n", loc, to_hex(&working).to_string())
            },

            DirectiveExpr { directive, args } =>
            {
                let loc = usize::try_from(args[0].lit.parse::<i32>().unwrap_or(0)).unwrap();
                let decoding = self.decode_directive(loc, &directive, &args);
                working.push_str(&decoding);
                return format!("{}", working).to_string()
            },

            LabelledExpr { label: _ , expr } =>
            {
                return self.decode_line(loc, expr);
            }

            _ => format!("{:04x} : {};\n", loc, to_hex("0000000000000000")).to_string(),
        }
    }

    // eval first adds all symbols into the symbol table, then it resolves all symbols,
    // producing binary representations for all instructions, etc.
    // It then translates these instructions to hexadecimal.
    pub fn eval(&mut self) -> String
    {
        let lines = self.create_memory();
        let mut out = String::new();
        for line in lines.iter()
        {
            out.push_str(&self.decode_line(line.loc, &line.expr));
        }
        return out.to_string()
    }
}
