module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = "form" Id form_id Block block; 

// TODO: question, computed question, block, if-then-else, if-then
syntax Question
  = question: Str question Id answer_id ": " Type answer_type
  | computed_question: Str Id ": " Type "=" Expr
  | ifthen: "if (" Expr ")" Block
  | ifthenelse: "if (" Expr ")" Block "else {" Expr "}" Block
  ;

	
syntax Block
	= "{" Question questions * "}";


// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr 
  = Id \ "true" \ "false" // true/false are reserved keywords.
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
  
lexical Str =  ![]* ;
		
lexical Int 
  =[0-9]* ;

lexical Bool = "true" | "false";
