use std::fmt::{Display, Formatter, Error};

// This module contains a hand-built parser. It has the structure to implement recursive-descent
// parsing if the language contained nested Exprs. However, because assembly language is mostly
// flat. It's really just a nice way to chunk Exprs (under Node) into lines.
// The parser also provides advanced error functionality. If the parser encounters a parse error,
// it stores the error and this is printed out in the main assembly loop.

use crate::lexer;
use crate::lexer::Token;
use crate::lexer::Lexer;
use crate::lexer::TokenType;
use crate::lexer::TokenType::{
    EOF,
    INT,
    STRING,
    COMMA,
    COLON,
    NEWLINE,
    REGISTER,
};

use self::Node::{
    DirectiveExpr,
    LabelledExpr,
    InstructionExpr,
    NullExpr,
};

#[derive(Debug, Clone)]
pub enum Node
{
    DirectiveExpr { directive: Token, args: Vec<Token> },
    InstructionExpr { instruction: Token, operands: Vec<Token> },
    LabelledExpr { label: Token, expr: Box<Node> },
    NullExpr,
}

pub struct Program {
    pub exprs: Vec<Node>
}

impl Display for Program {
    fn fmt(&self, f: &mut Formatter) -> Result<(), Error> {
        let mut counter = 0;
        let mut comma_separated = String::new();
        for expr in &self.exprs[0..self.exprs.len()] {
            comma_separated.push_str(&format!("{} -> {:?}\n", counter, expr).to_string());
            counter += 1;
        }
        write!(f, "\n{}", comma_separated)
    }
}

#[derive(Debug)]
pub struct Parser
{
    l: Lexer,
    errors: Vec<String>,
    curr_token: Token,
    peek_token: Token,
}

impl Parser
{
    pub fn new(mut l: Lexer) -> Parser 
    {
        let curr_token = l.next_token();
        let peek_token = l.next_token();
        let p = Parser{ l: l , errors: Vec::<String>::new(), curr_token: curr_token, peek_token: peek_token };
        return p
    }

    pub fn next_token(&mut self)
    {
        self.curr_token = self.peek_token.clone();
        self.peek_token = self.l.next_token();
    }

    pub fn expect_next(&mut self, tt: TokenType) -> bool
    {
        if self.peek_token.tt == tt
        {
            self.next_token();
            return true
        }
        else
        {
            self.expect_error(tt);
            return false
        }
    }

    pub fn expect_next_of_type(&mut self, arr_tt: Vec<TokenType>) -> bool
    {
        if arr_tt.contains(&self.peek_token.tt)
        {
            self.next_token();
            return true
        }
        else
        {
            self.expect_error_not_in_arr(arr_tt);
            return false
        }
    }

    pub fn expect_error(&mut self, tt: TokenType) -> ()
    {
        let msg = format!("expected next token to be {:?}, got {:?} instead",
            tt, self.peek_token.tt);
        self.errors.push(msg);
    }

    pub fn expect_error_not_in_arr(&mut self, arr_tt: Vec<TokenType>) -> ()
    {
        let msg = format!("expected next token to be one of the following {:?}, got {:?} instead",
            arr_tt, self.peek_token.tt);
        self.errors.push(msg);
    }

    pub fn parse_program(&mut self) -> Program 
    {
        let exprs = Vec::<Node>::new();
        let mut program = Program { exprs: exprs };
        while self.curr_token.tt != EOF 
        {
            let stmt = self.parse_expr();
            if stmt.is_some()
            {
                program.exprs.push(stmt.unwrap());
            }
            self.next_token()
        }
        return program
    }

    fn parse_expr(&mut self) -> Option<Node> {
        let stmt = match self.curr_token.tt {
            lexer::TokenType::DIRECTIVE(lexer::DirectiveType::LABEL) => {
                self.parse_labelled_expr()
            },
            lexer::TokenType::DIRECTIVE(_) => {
                self.parse_directive_expr()
            },
            lexer::TokenType::INSTRUCTION(_) => {
                self.parse_instruction_expr()
            },

            _ => {
                None
            }
        };
        return stmt
    }

    fn parse_labelled_expr(&mut self) -> Option<Node>
    {
        let label = self.curr_token.clone();
        if !self.expect_next(COLON)
        {
            return Some(LabelledExpr { label: label, expr: Box::new(NullExpr) })
        }
        self.next_token();
        let expr = self.parse_expr();
        if expr.is_some()
        {
            let boxed_expr = Box::new(expr.unwrap());
            return Some(LabelledExpr { label: label, expr: boxed_expr })
        }
        else
        {
            return None
        }
    }

    fn parse_instruction_expr(&mut self) -> Option<Node>
    {
        let instruction = self.curr_token.clone();
        let mut operands = Vec::<Token>::new();
        while self.curr_token.tt != EOF && self.curr_token.tt != NEWLINE
        {
            if !(self.expect_next_of_type(vec![REGISTER, INT { sign: true }, INT { sign : false }, lexer::TokenType::DIRECTIVE(lexer::DirectiveType::LABEL)]))
            {
                return None
            }
            operands.push(self.curr_token.clone());
            if !(self.expect_next_of_type(vec![COMMA, EOF, NEWLINE]))
            {
                return None
            }
        }
        return Some( InstructionExpr { instruction: instruction, operands: operands })
    }

    fn parse_directive_expr(&mut self) -> Option<Node>
    {
        let directive = self.curr_token.clone();
        let mut args = Vec::<Token>::new();
        while self.curr_token.tt != EOF && self.curr_token.tt != NEWLINE
        {
            if !self.expect_next_of_type(vec![INT { sign : true }, INT { sign : false }, STRING])
            {
                return None
            }
            args.push(self.curr_token.clone());
            if !(self.expect_next_of_type(vec![COMMA, EOF, NEWLINE]))
            {
                return None
            }
        }
        return Some( DirectiveExpr { directive: directive, args: args } )
    }
}
