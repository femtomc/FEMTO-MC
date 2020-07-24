#![allow(unused_imports)]
#[cfg(test)]
use crate::lexer::Lexer;
use crate::lexer::TokenType::{
    EOF,
    INT,
    STRING,
    COMMA,
    COMMENT,
    COLON,
    NEWLINE,
    LPAREN,
    RPAREN,
    REGISTER,
    DIRECTIVE,
    INSTRUCTION,
    ILLEGAL
};

use crate::lexer::DirectiveType::{
    ASCII,
    ASCIIZ,
    SPACE,
    WORD,
    HALF,
    BYTE,
    ORG,
    LABEL,
    ALIGN,
    ILLEGAL_DIRECTIVE,
};

use crate::lexer::InstructionType::{
    ADD,
    LOG,
    MEM,
    BEQ,
    JUMP,
    LUI,
    ADDI,
    SHIFTL,
    SHIFTR,
    ILLEGAL_INSTRUCTION,
};

use crate::parser;
use crate::assembler;

#[test]
fn test_twos_complement()
{
    let inp = -127;
    let x = assembler::twos_complement(inp);
    print!("Twos complement: {}\n", x);
}

#[test]
fn test_next_token()
{
    let input = ".asciiz \"enter first number\n\"
            (JUMP): add R1, R2";

                    let expected = [
                        (DIRECTIVE(ASCIIZ), "asciiz"), 
                        (STRING, "enter first number\n"),
                        (NEWLINE, "\n"),
                        (DIRECTIVE(LABEL), "JUMP"),
                        (COLON, ":"),
                        (INSTRUCTION(ADD), "add"),
                        (REGISTER, "1"),
                        (COMMA, ","),
                        (REGISTER, "2"),
                        (EOF, ""),
                    ];

                    let mut l = Lexer::new(input.to_string());
                    for i in expected.iter()
                    {
                        let tok = l.next_token();
                        assert_eq!(tok.lit, i.1);
                    }
}

#[test]
fn test_labelled_expr()
{
    let input = "(JUMP): .asciiz \"enter your word\n\"
    log R1, (JUMP)
    add R2, R3";
    let l = Lexer::new(input.to_string());
    let mut p = parser::Parser::new(l);
    let program = p.parse_program();
    print!("{}\n", program);
}

#[test]
fn test_assembler()
{
    let input =".asciiz \"enter first number\n\"
.asciiz \"enter second number\n\"
(LABEL_1): add R3, R5, 50";


         let l = Lexer::new(input.to_string());
         let mut p = parser::Parser::new(l);
         let mut asm = assembler::Assembler::new(p);
         let out = asm.eval();
         print!("Out:\n{}\n", out);
}
