module Check

import AST;
import Resolve;
import Message; // see standard library
import Set;

data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str label, Type \type];

// To avoid recursively traversing the form, use the `visit` construct
// or deep match (e.g., `for (/question(...) := f) {...}` ) 
TEnv collect(AForm f) {
	rel[loc def, str name, str label, Type \type] tenv = {};
	RefGraph rg = resolve(f);
	
	for (/question(str question, AId answer_id, AType answer_type) := f) {
		if (answer_type is integer) {
			if (<question, d> <- rg<1>) {
				tenv += <d, question, answer_id.name, tint()>;
			}
		}
		
		if (answer_type is boolean) {
			if (<question, d> <- rg<1>) {
				tenv += <d, question, answer_id.name, tbool()>;
			}
		}
		
		if (answer_type is string) {
			if (<question, d> <- rg<1>) {
				tenv += <d, question, answer_id.name, tstr()>;
			}
		}
		
	}

    return tenv; 
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
	set[Message] msgs = {};
	
	for (AQuestion q <- f.questions) {
		msgs += check(q, tenv, useDef);
	}

  	return msgs; 
}

// - produce an error if there are declared questions with the same name but different types.
// - duplicate labels should trigger a warning 
// - the declared type computed questions should match the type of the expression.
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
	set[Message] msgs = {};
	
	set[Type] types = {};
	set[loc] questions = {};
	
	if (q is question) {
		for (<str question, _, _, _, _> <- q , <_, question, _, Type t> <- tenv) {
			types += {t};
		}
		
		if (size(types) != 0) {
			msgs += {error("Declared question with same name and different type", q.src)};
		}
		
		if (<_, AId answer_id, _, _> <- q) {
			for (<str name, _> <- answer_id, <loc l, _, name, _> <- tenv) {
				questions += {l};
			}
		}
		
		if (size(questions) > 1) {
			msgs += {warning("This label is not unique", q.src)};
		}
		
	}
	
	if (q is compquestion) {
		for (<str question, _, _, _, _, _> <- q , <_, question, _, Type t> <- tenv) {
			types += {t};
		}
		
		if (size(types) != 0) {
			msgs += {error("Declared question with same name and different type", q.src)};
		}
		
		if (<_, AId answer_id, _, _, _> <- q) {
			for (<str name, _> <- answer_id, <loc l, _, name, _> <- tenv) {
				questions += {l};
			}
		}
		
		if (size(questions) > 1) {
			msgs += {warning("This label is not unique", q.src)};
		}
		
		if (<_, _, AType answer_type, AExpr answer_calc> <- q) {
			msgs += check(answer_calc, tenv, useDef);
			Type \type = typeOf(answer_calc, tenv, useDef);
			
			if (answer_type is integer && \type is tint) {
				msgs += {};
			} else if (answer_type is boolean && \type is tbool) {
				msgs += {};
			} else if (answer_type is string && \type is tstr) {
				msgs += {};
			} else {
				msgs += {error("Given type is not the same as the calculated type", q.src)};
			}
		}
	}
	
	if (q is ifthen) {
		if (<AExpr guard, list[AQuestion] questions> <- q) {
			for (AQuestion qu <- questions) {
				msgs += check(qu, tenv, useDef);
			}
			
			msgs += check(guard, tenv, useDef);
			
			if (typeOf(guard, tenv, useDef) is tbool) {
				msgs += {};
			} else {
				msgs += {error("Expression within guards does not result in a boolean", q.src)};
			}
		}
	}
	
	if (q is ifthenelse) {
		if (<AExpr guard, list[AQuestion] if_block, list[AQuestion] else_block> <- q) {
			for (AQuestion qu <- if_block) {
				msgs += check(qu, tenv, useDef);
			}
			
			for (AQuestion qu <- else_block) {
				msgs += check(qu, tenv, useDef);
			}
			
			msgs += check(guard, tenv, useDef);
			
			if (typeOf(guard, tenv, useDef) is tbool) {
				msgs += {};
			} else {
				msgs += {error("Expression within guards does not result in a boolean", q.src)};
			}
		}
	}

  	return msgs; 
}

// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
	set[Message] msgs = {};
  
  	switch (e) {
    	case ref(AId x):
      		msgs += { error("Undeclared question", x.src) | useDef[x.src] == {} };
      		
      	default:
      		msgs += { error("Incompatible operator", e.src) | typeOf(e, tenv, useDef) == tunknown() };
	}
  
  return msgs; 
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
	switch (e) {
		case ref(id(_, src = loc u)):  
      		if (<u, loc d> <- useDef, <d, _, _, Type t> <- tenv) {
        		return t;
      		}
      		
      	case hk(AExpr arg):
      		return typeOf(arg, tenv, useDef);
      		
      	case pl(AExpr arg):
      		if (typeOf(arg, tenv, useDef) == tint()) {
      			return tint();
      		} 
      		
      	case mi(AExpr arg):
      		if (typeOf(arg, tenv, useDef) == tint()) {
      			return tint();
      		} 
      		
      	case not(AExpr arg):
      		if (typeOf(arg, tenv, useDef) == tbool()) {
      			return tint();
      		}
      		
      	case mul(AExpr lhs, AExpr rhs):
      		if (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint()) {
      			return tint();
      		}
      		
      	case div(AExpr lhs, AExpr rhs):
      		if (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint()) {
      			return tint();
      		}
      		
      	case mo(AExpr lhs, AExpr rhs):
      		if (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint()) {
      			return tint();
      		}
      		
      	case add(AExpr lhs, AExpr rhs):
      		if (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint()) {
      			return tint();
      		}
      		
      	case sub(AExpr lhs, AExpr rhs):
      		if (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint()) {
      			return tint();
      		}
      		
      	case gt(AExpr lhs, AExpr rhs):
      		if (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint()) {
      			return tbool();
      		}
      		
      	case lt(AExpr lhs, AExpr rhs):
      		if (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint()) {
      			return tbool();
      		}
      		
      	case geq(AExpr lhs, AExpr rhs):
      		if (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint()) {
      			return tbool();
      		}
      		
      	case leq(AExpr lhs, AExpr rhs):
      		if (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint()) {
      			return tbool();
      		}
      		
      	case iseq(AExpr lhs, AExpr rhs):
      		if ((typeOf(lhs, tenv, useDef)) == (typeOf(rhs, tenv, useDef)) && typeOf(lhs, tenv, useDef) != tunknown()) {
      			return tbool();
      		}
      		
      	case neq(AExpr lhs, AExpr rhs):
      		if ((typeOf(lhs, tenv, useDef)) == (typeOf(rhs, tenv, useDef)) && typeOf(lhs, tenv, useDef) != tunknown()) {
      			return tbool();
      		}
      		
      	case geq(AExpr lhs, AExpr rhs):
      		if (typeOf(lhs, tenv, useDef) == tbool() && typeOf(rhs, tenv, useDef) == tbool()) {
      			return tbool();
      		}
      		
      	case geq(AExpr lhs, AExpr rhs):
      		if (typeOf(lhs, tenv, useDef) == tbool() && typeOf(rhs, tenv, useDef) == tbool()) {
      			return tbool();
      		}
      		
    // etc.
  	}
  	return tunknown(); 
}

/* 
 * Pattern-based dispatch style:
 * 
 * Type typeOf(ref(id(_, src = loc u)), TEnv tenv, UseDef useDef) = t
 *   when <u, loc d> <- useDef, <d, x, _, Type t> <- tenv
 *
 * ... etc.
 * 
 * default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
 *
 */
 
 

