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

AForm cst2ast(fo:(Form) `form <Id f> <Block b>`) {
  return form("<f>", cst2ast(b), src=fo@\loc);
}

AQuestion cst2ast(qu:(Question) `<Str* ss>`) {
  return question(["<s>" | Str s <- ss], src=qu@\loc);
}


ACompQuestion cst2ast(cq:(CompQuestion) `<Str* ss> <Int* ii>`){
  return compquestion(["<s>" | Str s <- ss], [i | Int i <- ii], src=cq@\loc);
}

ABlock cst2ast((Block) `{<Question* qq> <CompQuestion* cc> <IfThen* itt>}`){
  return block([cst2ast(q) | q <- qq], [cst2ast(c) | c <- cc], [cst2ast(it) | it <- itt]);
}

AIfThen cst2ast(IfThen i){
  throw "Not yet implemented";
}


AExpr cst2ast(ex:Expr e) {
  switch (e) {
    case (Expr)`ex:<Id x>`: return ref(id("<x>", src=ex@\loc), src=ex@\loc);
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
    
    default: throw "Unhandled expression: <e>";
  }
}




AType cst2ast(Type t) {
  throw "Not yet implemented";
}
