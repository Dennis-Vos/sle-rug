module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 /

start syntax Form 
  = "form" Id "{" Question "}"; 

// TODO: question, computed question, block, if-then-else, if-then
syntax Question
  = Str*
  | (Str | Expr)*
  ; 



syntax CompQuestion
    = (Str | Expr)*
    ;


syntax Block
    = "{" (Question | CompQuestion | IfThen)* "}"
    ;


syntax IfThen
    = ifthen: "if (" Expr ")" Block
    | ifthenelse: "if (" Expr ")" Block "else {" Expr "}" Block
    ;


// TODO: +, -, , /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
//syntax Expr 
//  = Id \ "true" \ "false" // true/false are reserved keywords.
//  |left Expr "+" Expr
//  |left Expr "-" Expr
//  |left Expr "" Expr
//  |left Expr "/" Expr
//  |left Expr "&&" Expr
//  |left Expr "||" Expr
//  |left "!" Expr
//  |left Expr ">" Expr
//  |left Expr "<" Expr
//  |left Expr ">=" Expr
//  |left Expr "<=" Expr
//  |left Expr "==" Expr
//  |left Expr "!=" Expr
//   ;

syntax Type
  = Str | Int | Bool;

lexical Str = "\"" [a-zA-Z]* "\"";

lexical Int 
  = [0-9]*;

lexical Bool = "true" | "false";
