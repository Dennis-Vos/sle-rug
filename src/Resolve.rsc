module Resolve

import AST;

/*
 * Name resolution for QL
 */ 


// modeling declaring occurrences of names
alias Def = rel[str name, loc def];

// modeling use occurrences of names
alias Use = rel[loc use, str name];

alias UseDef = rel[loc use, loc def];

// the reference graph
alias RefGraph = tuple[
  Use uses, 
  Def defs, 
  UseDef useDef
]; 

RefGraph resolve(AForm f) = <us, ds, us o ds>
  when Use us := uses(f), Def ds := defs(f);

Use uses(AForm f) {
	Use u
	= { <e.id.src, e.id.name> | /AExpr e := f, e is ref };
	
	return u; 
}

Def defs(AForm f) {
	Def d
	= { <q.answer_id.name, q.src> | /AQuestion q := f, q is question || q is compquestion };
	
	return d;
}