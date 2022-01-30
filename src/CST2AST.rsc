module CST2AST

import Syntax;
import AST;

import ParseTree;
import String;
import Boolean;

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
	  return question("<qu.question>", cst2ast(qu.answer_id), cst2ast(qu.answer_type), src=qu@\loc);}
	else if (qu is computed_question){
	  return compquestion("<qu.question>", cst2ast(qu.answer_id), cst2ast(qu.answer_type), cst2ast(qu.answer_calc), src=qu@\loc);}
	else if (qu is ifthen){
	  return ifthen(cst2ast(qu.guard), [cst2ast(q) | q <- qu.block.questions], src=qu@\loc);}
	else if (qu is ifthenelse){
	  return ifthenelse(cst2ast(qu.guard), [cst2ast(q) | q <- qu.if_block.questions], [cst2ast(q) | q <- qu.else_block.questions], src=qu@\loc);}
	  
	throw "Unsupported question <qu>"; 
}

AExpr cst2ast(ex:Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref(cst2ast(x), src=ex@\loc);
    case (Expr)`<Int i>`: return integer(toInt("<i>"), src=ex@\loc);
    case (Expr)`<Bool b>`: return boolean(fromString("<b>"), src=ex@\loc);
    case (Expr) `(<Expr e>)`: return cst2ast(e);
    case (Expr) ` +<Expr e>`: return pl(cst2ast(e), src=ex@\loc);
    case (Expr) ` -<Expr e>`: return mi(cst2ast(e), src=ex@\loc);
    case (Expr) `!<Expr e>`: return not(cst2ast(e), src=ex@\loc); 
    case (Expr) `<Expr lhs> * <Expr rhs>`: return mul(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `<Expr lhs> / <Expr rhs>`: return div(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `<Expr lhs> % <Expr rhs>`: return mo(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `<Expr lhs> + <Expr rhs>`: return add(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `<Expr lhs> - <Expr rhs>`: return sub(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `<Expr lhs> \> <Expr rhs>`: return gt(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `<Expr lhs> \< <Expr rhs>`: return lt(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `<Expr lhs> \>= <Expr rhs>`: return geq(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `<Expr lhs> \<= <Expr rhs>`: return leq(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `<Expr lhs> == <Expr rhs>`: return iseq(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `<Expr lhs> != <Expr rhs>`: return neq(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `<Expr lhs> && <Expr rhs>`: return and(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    case (Expr) `<Expr lhs> || <Expr rhs>`: return or(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    
    default: throw "Unsupported expression <e>";
  }
}

AId cst2ast(Id i) {
  return id("<i>", src=i@\loc);
}

AType cst2ast(Type t) {
	if (t is integer) {
		return integer(src=t@\loc);
	}
	else if (t is boolean) {
		return boolean(src=t@\loc);
	}
	else if (t is string) {
		return string(src=t@\loc);
	}
	
	throw "Unsupported type <t>";    
}