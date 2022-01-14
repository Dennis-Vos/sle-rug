module CST2AST

import Syntax;
import AST;

import ParseTree;
import String;

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 *
 * - Use switch to do case distinction with concrete patterns (like in Hack your JS) 
 * - Map regular CST arguments (e.g., *, +, ?) to lists 
 *   (NB: you can iterate over * / + arguments using `<-` in comprehensions or for-loops).
 * - Map lexical nodes to Rascal primitive types (bool, int, str)
 * - See the ref example on how to obtain and propagate source locations.
 */

AForm cst2ast(start[Form] sf) {
  Form f = sf.top; // remove layout before and after form
  return cst2ast(f); 
}

AForm cst2ast(Form fo){
  return form("<fo.form_id>", [cst2ast(qu) | qu <- fo.block.questions] , src=fo@\loc);
}

AQuestion cst2ast(Question qu) {
	if (qu is question){
	  return question("<qu.question>", cst2ast(qu.anwser_id), cst2ast(qu.answer_type), src=qu@\loc);}
	if (qu is computed_question){
	  return computed_question("<qu.question>", cst2ast(qu.anwser_id), cst2ast(qu.answer_type), cst2ast(qu.answer_calc), src=qu@\loc);}
	if (qu is ifthen){
	  return ifthen(cst2ast(qu.guard), cst2ast(qu.block), src=qu@\loc);}
	if (qu is ifthenelse){
	  return ifthenelse(cst2ast(qu.guard), cst2ast(qu.if_block), cst2ast(qu.guard), cst2ast(qu.else_block), src=qu@\loc);}
}

AExpr cst2ast(ex:Expr e) {
  switch (e) {
    case (Expr)`ex:<Id x>`: return ref(id("<x>", src=ex@\loc), src=ex@\loc);
    case (Expr) `ex:(<Expr e>)`: return cst2ast(e);
    case (Expr) `ex:+<Expr e>`: return pl(cst2ast(e), src=ex@\loc);
    case (Expr) `ex:-<Expr e>`: return mi(cst2ast(e), src=ex@\loc);
    case (Expr) `ex:!<Expr e>`: return not(cst2ast(e), src=ex@\loc);
    case (Expr) `ex:<Expr lhs> * <Expr rhs>`: return mul(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `ex:<Expr lhs> / <Expr rhs>`: return div(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `ex:<Expr lhs> % <Expr rhs>`: return mo(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `ex:<Expr lhs> + <Expr rhs>`: return add(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `ex:<Expr lhs> - <Expr rhs>`: return sub(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `ex:<Expr lhs> \> <Expr rhs>`: return gt(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `ex:<Expr lhs> \< <Expr rhs>`: return lt(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `ex:<Expr lhs> \>= <Expr rhs>`: return geq(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `ex:<Expr lhs> \<= <Expr rhs>`: return leq(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `ex:<Expr lhs> == <Expr rhs>`: return iseq(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `ex:<Expr lhs> != <Expr rhs>`: return neq(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `ex:<Expr lhs> && <Expr rhs>`: return and(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `ex:<Expr lhs> || <Expr rhs>`: return or(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
  }
}

AId cst2ast(Id i) {
  return id("<i>", src=i@\loc);
}

AType cst2ast(Type t) {
  throw "not yet implemented";
}