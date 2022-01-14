module AST

/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|)
  = form(str name, list[AQuestion] questions)
  ; 

data AQuestion(loc src = |tmp:///|)
  = question(str question, AId answer_id, AType answer_type)
  | compquestion(str question, AId answer_id, AType answer_type,  AExpr answer_calc)
  | ifthen(AExpr guard, AQuestion question)
  | ifthenelse(AExpr guard, AQuestion if_block, AExpr guard2, AQuestion else_block)
  ; 
 

data AExpr(loc src = |tmp:///|)
  = ref(AId id)
  | hk(AExpr)
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
  = boolean()
  | integer()
  | string()
  ;
