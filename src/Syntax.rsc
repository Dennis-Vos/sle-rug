module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = "form" Id form_id Block block; 
  
  
syntax Block
  = "{" Question* questions "}";
  

// TODO: question, computed question, block, if-then-else, if-then
syntax Question
  = question: Str question Id answer_id ": " Type answer_type
  | computed_question: Str question Id answer_id ": " Type answer_type "=" Expr answer_calc
  | ifthen: "if" "(" Expr guard ")" Block block
  | ifthenelse: "if" "(" Expr guard ")" Block if_block "else" Block else_block
  ;



// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr 
  = Id \ "true" \ "false"  // true/false are reserved keywords.
  |Int
  |left "(" Expr ")"
  |right "+" Expr
  |right "-" Expr
  |right "!" Expr
  |left Expr "*" Expr
  |left Expr "/" Expr
  |left Expr "%" Expr
  |left Expr "+" Expr
  |left Expr "-" Expr
  |non-assoc Expr "\>" Expr
  |non-assoc Expr "\<" Expr
  |non-assoc Expr "\>=" Expr
  |non-assoc Expr "\<=" Expr
  |left Expr "==" Expr
  |left Expr "!=" Expr
  |left Expr "&&" Expr
  |left Expr "||" Expr  
   ;

  
syntax Type
  = integer: "integer"
  | boolean: "boolean"
  | string: "string"
;
  
lexical Str =  "\""[a-zA-Z0-9?:\t-\n\r\ ]*"\"" ;

lexical Int = [0-9]*;

lexical Bool = "true" | "false";
