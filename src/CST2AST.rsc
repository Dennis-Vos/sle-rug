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
  return form("", [], src=f@\loc); 
}

AQuestion cst2ast(Question q) {
  throw "Not yet implemented";
}

ACompQuestion cst2ast(CompQuestion c){
  throw "Not yet implemented";
}

ABlock cst2ast(Block b){
  throw "Not yet implemented";
}

AIfThen cst2ast(IfThen i){
  throw "Not yet implemented";
}


AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref(id("<x>", src=x@\loc), src=x@\loc);
    
    case (Expr) `!<Expr e>`: return not(cst2ast(e), src=e@\loc);
    
    case (Expr) `ex:<Expr lhs> || <Expr rhs>`: return or(cst2ast(lhs), cst2ast(rhs), src=ex@\loc);
    default: throw "Unhandled expression: <e>";
  }
}




AType cst2ast(Type t) {
  throw "Not yet implemented";
}
