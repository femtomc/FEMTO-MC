#![allow(dead_code, non_camel_case_types)]

// This module contains a hand-built lexer. I thought this would aid in more advanced assembler
// functionality (and debugging) if I got a chance to spend some time on it.

pub use self::TokenType::{
    EOF,
    INT,
    STRING,
    IDENT,
    COMMENT,
    COMMA,
    COLON,
    NEWLINE,
    LPAREN,
    RPAREN,
    REGISTER,
    DIRECTIVE,
    INSTRUCTION,
    ILLEGAL
};

pub use self::DirectiveType::{
    ASCII,
    ASCIIZ,
    CONST,
    SPACE,
    WORD,
    HALF,
    BYTE,
    ORG,
    LABEL,
    ALIGN,
    ILLEGAL_DIRECTIVE,
};

pub use self::InstructionType::{
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

#[derive(Debug, Clone, PartialEq)]
pub enum TokenType {
    EOF,
    INT { sign: bool },
    STRING,
    IDENT,
    COMMENT,
    COMMA,
    COLON,
    NEWLINE,
    LPAREN,
    RPAREN,
    LABEL,
    REGISTER,
    DIRECTIVE(DirectiveType),
    INSTRUCTION(InstructionType),
    ILLEGAL,
}

#[derive(Debug, Clone, PartialEq)]
pub enum DirectiveType
{
    ASCII,
    ASCIIZ,
    SPACE,
    CONST,
    WORD,
    HALF,
    BYTE,
    ORG,
    LABEL,
    ALIGN,
    ILLEGAL_DIRECTIVE,
}

#[derive(Debug, Clone, PartialEq)]
pub enum InstructionType
{
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
}


#[derive(Debug, Clone)]
pub struct Token
{
    pub tt: TokenType,
    pub lit: String,
}

#[derive(Debug)]
pub struct Lexer
{
    input: String,
    position: usize,
    read_position: usize,
    ch: u8,
}

impl Lexer {
    pub fn new(inp: String) -> Lexer
    {
        let mut l = Lexer { 
            input: inp, 
            position: 0, 
            read_position: 0, 
            ch: 0,
        };

        l.read_char();
        return l
    }

    pub fn lookup_instruction(&self, key: &str) -> InstructionType
    {
        let tok = match key
        {
            "add" => ADD, 
            "log"=> LOG, 
            "mem" => MEM,
            "beq" => BEQ,
            "jump" => JUMP, 
            "addi" => ADDI,
            "lui" => LUI,
            "shiftl" => SHIFTL,
            "shiftr" => SHIFTR,
            _ => ILLEGAL_INSTRUCTION,
        };
        return tok
    }

    pub fn lookup_directive(&self, key: &str) -> DirectiveType
    {
        let tok = match key
        {
            "asciiz" => ASCIIZ,
            "ascii" => ASCII,
            "space" => SPACE,
            "const" => CONST,
            "word" => WORD,
            "half" => HALF,
            "byte" => BYTE, 
            "org" => ORG, 
            "label" => LABEL,
            "align" => ALIGN,
            _ => ILLEGAL_DIRECTIVE,
        };
        return tok
    }

    pub fn read_char(&mut self) -> ()
    {
        if self.read_position >= self.input.len()
        {
            self.ch = 0
        }
        else
        {
            self.ch = self.input.as_bytes()[self.read_position]
        }
        self.position = self.read_position;
        self.read_position += 1
    }

    pub fn read_identifier(&mut self) -> String
    {
        let position = self.position;
        if is_letter(self.ch)
        {
            self.read_char()
        }

        while is_letter(self.ch) || is_digit(self.ch)
        {
            self.read_char()
        }
        return self.input[position..self.position].to_string()
    }

    pub fn read_string(&mut self) -> String
    {
        let position = self.position;
        while self.ch != b'"' && self.ch != b'\0'
        {
            self.read_char()
        }
        return self.input[position..self.position].to_string()
    }

    pub fn read_until_eof(&mut self) -> String
    {
        let position = self.position;
        while self.ch != b'\0' && self.ch != b'\n'
        {
            self.read_char()
        }
        return self.input[position..self.position].to_string()
    }

    pub fn read_number(&mut self) -> &str {
        let position = self.position;
        while is_digit(self.ch) {
            self.read_char()
        }
        return &self.input[position..self.position]
    }

    pub fn skip_whitespace(&mut self) -> ()
    {
        while self.ch == b' ' || self.ch == b'\t'
        {
            self.read_char()
        }
    }

    pub fn peek_char(&mut self) -> u8 
    {
        if self.read_position >= self.input.len()
        {
            return 0
        } 
        else 
        {
            return self.input.as_bytes()[self.read_position]
        }
    }

    pub fn next_token(&mut self) -> Token
    {
        self.skip_whitespace();
        let tok = match self.ch
        {
            b'(' => {
                self.read_char();
                let lit = self.read_identifier();
                if self.ch != b')'
                {
                    return Token { tt: ILLEGAL, lit: self.ch.to_string() }
                }
                else
                {
                    self.read_char();
                    return Token { tt: DIRECTIVE(LABEL), lit: lit }
                }
            }

            b':' => Token { tt: COLON, lit: ":".to_string() },

            b',' => Token { tt: COMMA, lit: ",".to_string() },

            b'\n' => Token { tt: NEWLINE, lit: "\n".to_string() },

            b'\0' => Token { tt: EOF, lit: "".to_string() },

            b'-' => {
                if self.peek_char() == b'-'
                {
                    self.read_char();
                    self.read_char();
                    self.skip_whitespace();
                    let _lit = self.read_until_eof();
                    Token { tt: NEWLINE, lit: "\n".to_string() }
                }
                else if is_digit(self.peek_char())
                {
                    self.read_char();
                    let lit = self.read_number();
                    Token { tt: INT { sign: true }, lit: lit.to_string() }
                }
                else
                {
                    let tok = Token { tt: ILLEGAL, lit: self.ch.to_string()};
                    return tok
                }
            }

            b'"' | b'\'' => {
                self.read_char();
                let phrase = self.read_string();
                self.read_char();
                return Token { tt: STRING, lit: phrase }
            }

            b'.' => {
                self.read_char();
                let lit = self.read_identifier();
                return Token { tt: DIRECTIVE(self.lookup_directive(&lit)), lit: lit.to_string() }
            }

            _ => {
                if is_letter(self.ch) {
                    if self.ch == b'R'
                    {
                        self.read_char();
                        let digit = self.read_number();
                        return Token { tt: REGISTER, lit: digit.to_string() };
                    }
                    else
                    {
                        let lit = self.read_identifier();
                        return Token { tt: INSTRUCTION(self.lookup_instruction(&lit)), lit: lit.to_string() }
                    }
                }
                else if is_digit(self.ch) {
                    let lit = self.read_number();
                    return Token { tt: INT { sign: false }, lit: lit.to_string() }
                }
                else
                {
                    let tok = Token { tt: ILLEGAL, lit: self.ch.to_string()};
                    return tok
                }
            }
        };

        self.read_char();
        return tok
    }
}

fn is_letter(ch: u8) -> bool
{
    return b'a' <= ch && ch <= b'z' || b'A' <= ch && ch <= b'Z' || ch == b'_'
}

fn is_digit(ch: u8) -> bool 
{
    return b'0' <= ch && ch <= b'9'
}
