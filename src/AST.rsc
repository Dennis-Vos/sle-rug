module AST

/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|)
  = form(str name, ABlock block)
  ; 

data AQuestion(loc src = |tmp:///|)
  = question(list[str])
  ; 
  
data ACompQuestion(loc src = |tmp:///|)
  = compquestion(list[str], list[int])
  ;   
  
data ABlock(loc src = |tmp:///|)
  = block(list[AQuestion] question, list[ACompQuestion] compquestion, list[AIfThen] ifthen)
  ; 

data AIfThen(loc src= |tmp:///|)
  = ifthen(AExpr expression, ABlock block)
  | ifthenelse(AExpr expression, ABlock block, AExpr expression2, ABlock block2)
  ;

data AExpr(loc src = |tmp:///|)
  = ref(AId id)
  | pl(AExpr arg)
  | mi(AExpr arg)
  | not(AExpr arg)
  | mul(AExpr lhs, AExpr rhs)
  | div(AExpr lhs, AExpr rhs)
  | mo(AExpr lhs, AExpr rhs)
  | add(AExpr lhs, AExpr rhs)
  | sub(AExpr lhs, AExpr rhs)
  | gt(AExpr lhs, AExpr rhs)
  | lt(AExpr lhs, AExpr rhs)
  | geq(AExpr lhs, AExpr rhs)
  | leq(AExpr lhs, AExpr rhs)
  | iseq(AExpr lhs, AExpr rhs)
  |	neq(AExpr lhs, AExpr rhs)
  | and(AExpr lhs, AExpr rhs)
  | or(AExpr lhs, AExpr rhs)
  ;


data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|)
  = Type(str Type) ;
