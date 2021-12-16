module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = "form" Id Block; 

// TODO: question, computed question, block, if-then-else, if-then
syntax Question
  = Str*
  ; 
  
  
  
syntax CompQuestion
	= (Str | Int)*
	;

	
syntax Block
	= "{" (Question | CompQuestion | IfThen)* "}"
	;
	
	
syntax IfThen
	= ifthen: "if (" Expr ")" Block
	| ifthenelse: "if (" Expr ")" Block "else {" Expr "}" Block
	;
  

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr 
  = Id \ "true" \ "false" // true/false are reserved keywords.
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
  = "integer" | "boolean";
  
lexical Str =  ![]* ;
		
lexical Int 
  =[0-9]* ;

lexical Bool = "true" | "false";
