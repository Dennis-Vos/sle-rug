module Eval

import AST;
import Resolve;

/*
 * Implement big-step semantics for QL
 */
 
// NB: Eval may assume the form is type- and name-correct.


// Semantic domain for expressions (values)
data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  ;

// The value environment
alias VEnv = map[str name, Value \value];

// Modeling user input
data Input
  = input(str question, Value \value);
  
// produce an environment which for each question has a default value
// (e.g. 0 for int, "" for str etc.)
VEnv initialEnv(AForm f) {
	return helpFunction(f.questions);
}


VEnv helpFunction(list[AQuestion] questions) {
	VEnv venv = ( );
	
	for (AQuestion q <- questions) {
		if (q is question || q is compquestion) {
			if (q.answer_type is integer) {
				venv[q.answer_id.name] = vint(0);
			}
			if (q.answer_type is boolean) {
				venv[q.answer_id.name] = vbool(true);
			}
			if (q.answer_type is string) {
				venv[q.answer_id.name] = vstr("");
			}
		}
		else {
			if (q is ifthen) {
				venv += helpFunction(q.questions);
			}
			else {
				venv += helpFunction(q.if_block);
				venv += helpFunction(q.else_block);
			}
		}
	}
	 
	return venv;
}
	

// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {	
	for (AQuestion q <- f.questions) {
		venv = eval(q, inp, venv);
	}
	
    return venv; 
}



VEnv eval(AQuestion q, Input inp, VEnv venv) {
  // evaluate conditions for branching,
  // evaluate inp and computed questions to return updated VEnv
	if (q is question && q.question == inp.question) {
		venv[q.answer_id.name] = inp.\value;
	}
	if (q is compquestion && q.question == inp.question) {
		venv[q.answer_id.name] = eval(q.answer_calc, venv);
	}
	if (q is ifthen) {
		for (AQuestion qu <- q.questions) {
			venv = eval(qu, inp, venv);
		}
	}
	if (q is ifthenelse) {
		for (AQuestion qu <- q.if_block) {
			venv = eval(qu, inp, venv);
		}
		
		for (AQuestion qu <- q.else_block) {
			venv = eval(qu, inp, venv);
		}
	}
	
	return venv; 
}



Value eval(AExpr e, VEnv venv) {
  switch (e) {
    case ref(id(str x)): return venv[x];
    case hk(AExpr arg): return eval(arg, venv);
    case pl(AExpr arg): return eval(arg, venv);
    case mi(AExpr arg): return vint(-eval(arg, venv).n);
    case not(AExpr arg): return vbool(!eval(arg, venv).b);
    case mul(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n * eval(rhs, venv).n);
    case div(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n / eval(rhs, venv).n);
    case mo(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n % eval(rhs, venv).n);
    case add(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n + eval(rhs, venv).n);
    case sub(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n - eval(rhs, venv).n);
    case gt(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n > eval(rhs, venv).n);
    case lt(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n < eval(rhs, venv).n);
    case geq(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n >= eval(rhs, venv).n);
    case leq(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n <= eval(rhs, venv).n);
    case iseq(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n == eval(rhs, venv).n);
    case neq(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n != eval(rhs, venv).n);
    case and(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).b && eval(rhs, venv).b);
    case or(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).b || eval(rhs, venv).b);    
    // etc.
    
    default: throw "Unsupported expression <e>";
  }
}