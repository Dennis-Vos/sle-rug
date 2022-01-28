module Transform

import Syntax;
import Resolve;
import AST;
import Set;

/* 
 * Transforming QL forms
 */
 
 
/* Normalization:
 *  wrt to the semantics of QL the following
 *     q0: "" int; 
 *     if (a) { 
 *        if (b) { 
 *          q1: "" int; 
 *        } 
 *        q2: "" int; 
 *      }
 *
 *  is equivalent to
 *     if (true) q0: "" int;
 *     if (true && a && b) q1: "" int;
 *     if (true && a) q2: "" int;
 *
 * Write a transformation that performs this flattening transformation.
 *
 */
 
list[AQuestion] helpFlatten(AExpr expr, list[AQuestion] questions) {
	list[AQuestion] newQuestions = [];
	
	for (AQuestion q <- questions) {
		if (q is question || q is compquestion) {
			newQuestions += ifthen(expr, [q]);
		}
		if (q is ifthen) {
			newQuestions += helpFlatten(and(expr, q.guard), q.questions);
		}
		if (q is ifthenelse) {
			newQuestions += helpFlatten(and(expr, q.guard), q.if_block);
			newQuestions += helpFlatten(and(expr, not(q.guard)), q.else_block);
		}
	}

	return questions;
}
 
AForm flatten(AForm f) {
	AExpr expr = ref(id("true"));
	list[AQuestion] questions = [];
	
	for (AQuestion q <- f.questions) {
		if (q is question || q is compquestion) {
			questions += ifthen(expr, [q]);
		}
		if (q is ifthen) {
			questions += helpFlatten(and(expr, q.guard), q.questions);
		}
		if (q is ifthenelse) {
			questions += helpFlatten(and(expr, q.guard), q.if_block);
			questions += helpFlatten(and(expr, not(q.guard)), q.else_block);
		}
	}
	
	return form(f.name, questions); 
}

/* Rename refactoring:
 *
 * Write a refactoring transformation that consistently renames all occurrences of the same name.
 * Use the results of name resolution to find the equivalence class of a name.
 *
 */
 
 start[Form] rename(start[Form] f, loc useOrDef, str newName, UseDef useDef) {
 
 	set[loc] toRename = {};
 	
 	toRename += { u | <loc u, useOrDef> <- useDef};
 	if (!isEmpty(toRename)) {
 		toRename += {useOrDef};
 	}
 	
 	if (<useOrDef, loc d> <- useDef) {
 		toRename += { u | <loc u, d> <- useDef};
 	}
 	
 	if (isEmpty(toRename)) {
 		return f;
 	} else {
 		return visit(f) {
 			case Id x => [Id]newName
 				when x@\loc in toRename
 				
 			case Question q => q[question=[Id]newName]
 				when s@\loc in toRename 
 		}
 	} 
 } 
 
 
 

