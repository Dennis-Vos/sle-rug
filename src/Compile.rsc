module Compile

import AST;
import Resolve;
import IO;
import lang::html5::DOM; // see standard library
import List;

/*
 * Implement a compiler for QL to HTML and Javascript
 *
 * - assume the form is type- and name-correct
 * - separate the compiler in two parts form2html and form2js producing 2 files
 * - use string templates to generate Javascript
 * - use the HTML5Node type and the `str toString(HTML5Node x)` function to format to string
 * - use any client web framework (e.g. Vue, React, jQuery, whatever) you like for event handling
 * - map booleans to checkboxes, strings to textfields, ints to numeric text fields
 * - be sure to generate uneditable widgets for computed questions!
 * - if needed, use the name analysis to link uses to definitions
 */

void compile(AForm f) {
  writeFile(f.src[extension="js"].top, form2js(f));
  writeFile(f.src[extension="html"].top, toString(form2html(f)));
}

HTML5Node form2html(AForm f) {
  return html(head(script(src("https://unpkg.com/react@17/umd/react.development.js"
  )),script(src("https://unpkg.com/react-dom@17/umd/react-dom.development.js"
  )),script(src("https://unpkg.com/@babel/standalone/babel.min.js"))),body(div(id("app")),
  script(\type("text/babel"),src("<f.src>.js"))));
}

str expression(AExpr e) {
	 switch (e) {
	    case ref(id(str x)): return x;
	    case hk(AExpr arg): return expression(arg);
	    case pl(AExpr arg): return expression(arg);
	    case mi(AExpr arg): return "-" + expression(arg);
	    case not(AExpr arg): return "!" + expression(arg); 
	    case mul(AExpr lhs, AExpr rhs): return expression(lhs) + "*" + expression(rhs);
	    case div(AExpr lhs, AExpr rhs): return expression(lhs) + "/" + expression(rhs);
	    case mo(AExpr lhs, AExpr rhs): return expression(lhs) + "%" + expression(rhs);
	    case add(AExpr lhs, AExpr rhs): return expression(lhs) + "+" + expression(rhs);
	    case sub(AExpr lhs, AExpr rhs): return expression(lhs) + "-" + expression(rhs);
	    case gt(AExpr lhs, AExpr rhs): return expression(lhs) + "\>" + expression(rhs);
	    case lt(AExpr lhs, AExpr rhs): return expression(lhs) + "\<" + expression(rhs);
	    case geq(AExpr lhs, AExpr rhs): return expression(lhs) + "\>=" + expression(rhs);
	    case leq(AExpr lhs, AExpr rhs): return expression(lhs) + "\<=" + expression(rhs);
	    case iseq(AExpr lhs, AExpr rhs): return expression(lhs) + "==" + expression(rhs);
	    case neq(AExpr lhs, AExpr rhs): return expression(lhs) + "!=" + expression(rhs);
	    case and(AExpr lhs, AExpr rhs): return expression(lhs) + "&&" + expression(rhs);
	    case or(AExpr lhs, AExpr rhs): return expression(lhs) + "||" + expression(rhs);   
	    // etc. 
	    
	    default: return "Unsupported expression <e>"; 
	} 
}

str form2js(AForm f) {
	list[AQuestion] questions = [];
	list[list[AQuestion]] flag = [];
	
	for (/AQuestion q := f) {
		questions + q;
	}
	
	AQuestion qu = head(questions);
	drop(1, questions);
	
  	return "<findVariables(f)>
	  	   '
	  	   'function stan() {
	  	   '	function handleChange(event) {
	  	   '		<qu.question> = event.target.value;
	  	   '	}
	  	   '	
	  	   '	function handleSubmit(event) {
	  	   '		event.preventDefault();
	  	   '		<if (head(questions) is question) { drop(1, questions); flag += questions;>
	  	   '			function_<head(questions).answer_id>();
	  	   '		<}>
	  	   '		<if (head(questions) is compquestion) {>
	  	   '			<head(questions).answer_id> = <expression(head(questions).answer_calc)>;
	  	   '			alert(<head(questions).question> + <head(questions).answer_id>);
	  	   '
	  	   '			ReactDOM.render(
	  	   '				\<button onClick={reset}\>Try again\</button\>,
	  	   '				document.getElementById(\"app\")
	  	   '			);
	  	   '		<}> 
	  	   '		<if (head(questions) is ifthen) {>
	  	   '			if (<head(questions).guard>) {
	  	   '				<if (isEmpty(head(questions).questions)) {>
	  	   '					ReactDOM.render(
	  	   '						\<button onClick={reset}\>Try again\</button\>,
	  	   '						document.getElementById(\"app\")
	  	   '					);
	  	   '				<} else { flag += head(questions).questions;>
	  	   '					function_<head(head(questions).questions).answer_id>();
	  	   '				<}>
	  	   '			}
	  	   '		<}>
	  	   '		<if (head(questions) is ifthenelse) {>
	  	   '			if (<head(questions).guard>) {
	  	   '				<if (isEmpty(head(questions).questions)) {>
	  	   '					ReactDOM.render(
	  	   '						\<button onClick={reset}\>Try again\</button\>,
	  	   '						document.getElementById(\"app\")
	  	   '					);
	  	   '				<} else { flag += head(questions).if_block;>
	  	   '					function_<head(head(questions).if_block).answer_id>();
	  	   '				<}>
	  	   '			} else {
	  	   '				<if (isEmpty(head(questions).questions)) {>
	  	   '					ReactDOM.render(
	  	   '						\<button onClick={reset}\>Try again\</button\>,
	  	   '						document.getElementById(\"app\")
	  	   '					);
	  	   '				<} else { flag += head(questions).else_block;>
	  	   '					function_<head(head(questions).else_block).answer_id>();
	  	   '				<}>
	  	   '			}
	  	   '		<}>
	       '	}
	  	   '
	  	   '	let message = (
	       '		\<form onSubmit={e =\> handleSubmit(e)}\>
	  	   '			\<label\>
	  	   '				<qu.question>
	  	   					<returnForm(qu)>
	  	   				\<label\>
	  	   				\<input type=\"submit\" value=\"Submit\" /\>
	  	   			\</form\>
	  	   		);
	  	   		
	  	   		ReactDOM.render(message, document.getElementById(\"app\"));
	  	   '}				
	  	   '
	  	   '<for (list[AQuestion] q <- flag) {>
	  	   '<recursive_form2js(q)>
	  	   '<}>
	  	   '
	  	   'function reset() {
	  	   '	stan();
	  	   '}
	  	   '
	  	   'stan(); 
	  	   '"; 
	
} 

str recursive_form2js(list[AQuestion] questions) {
	list[list[AQuestion]] flag = [];
	
	AQuestion qu = head(questions);
	drop(1, questions);
	
	return "function function_<qu.answer_id>() {
	  	   '	function handleChange(event) {
	  	   '		<qu.question> = event.target.value;
	  	   '	}
	  	   '	
	  	   '	function handleSubmit(event) {
	  	   '		event.preventDefault();
	  	   '		<if (head(questions) is question) { drop(1, questions); flag += questions;>
	  	   '			function_<head(questions).answer_id>();
	  	   '		<}>
	  	   '		<if (head(questions) is compquestion) {>
	  	   '			<head(questions).answer_id> = <expression(head(questions).answer_calc)>;
	  	   '			alert(<head(questions).question> + <head(questions).answer_id>);
	  	   '
	  	   '			ReactDOM.render(
	  	   '				\<button onClick={reset}\>Try again\</button\>,
	  	   '				document.getElementById(\"app\")
	  	   '			);
	  	   '		<}> 
	  	   '		<if (head(questions) is ifthen) {>
	  	   '			if (<head(questions).guard>) {
	  	   '				<if (isEmpty(head(questions).questions)) {>
	  	   '					ReactDOM.render(
	  	   '						\<button onClick={reset}\>Try again\</button\>,
	  	   '						document.getElementById(\"app\")
	  	   '					);
	  	   '				<} else { flag += head(questions).questions;>
	  	   '					function_<head(head(questions).questions).answer_id>();
	  	   '				<}>
	  	   '			}
	  	   '		<}>
	  	   '		<if (head(questions) is ifthenelse) {>
	  	   '			if (<head(questions).guard>) {
	  	   '				<if (isEmpty(head(questions).questions)) {>
	  	   '					ReactDOM.render(
	  	   '						\<button onClick={reset}\>Try again\</button\>,
	  	   '						document.getElementById(\"app\")
	  	   '					);
	  	   '				<} else { flag += head(questions).if_block;>
	  	   '					function_<head(head(questions).if_block).answer_id>();
	  	   '				<}>
	  	   '			} else {
	  	   '				<if (isEmpty(head(questions).questions)) {>
	  	   '					ReactDOM.render(
	  	   '						\<button onClick={reset}\>Try again\</button\>,
	  	   '						document.getElementById(\"app\")
	  	   '					);
	  	   '				<} else { flag += head(questions).else_block;>
	  	   '					function_<head(head(questions).else_block).answer_id>();
	  	   '				<}>
	  	   '			}
	  	   '		<}>
	       '	}
	  	   '
	  	   '	let message = (
	       '		\<form onSubmit={e =\> handleSubmit(e)}\>
	  	   '			\<label\>
	  	   '				<qu.question>
	  	   					<returnForm(qu)>
	  	   				\<label\>
	  	   				\<input type=\"submit\" value=\"Submit\" /\>
	  	   			\</form\>
	  	   		);
	  	   		
	  	   		ReactDOM.render(message, document.getElementById(\"app\"));
	  	   '}				
	  	   '
	  	   '<for (list[AQuestion] q <- flag) {>
	  	   '<recursive_form2js(q)>
	  	   '<}>
	  	   '"; 
	
}

str findVariables(AForm f) {
	return "<for (/AId id := f) {>
		   'let <id.name>;
		   '<}>	
		   '";
}

str returnForm(AQuestion question) {
	if (question.answer_type is integer) {
		return "\<input type=\"number\" value={question.answer_id.name} onChange={e = handleChange(e)} "; 
	} else if (question.answer_type is boolean) {
		return "\<select value={question.answer_id.name} onChange={e =\> handleChange(e)}\>
			   '	\<option value=\"\" disabled selected\>Select your option\<option\>
			   '	\<option value={true}\>Yes\</option\>
			   '	\<option value={false}\>No\</option\>
			   '\</select\>
			   '";
	} else if (question.answer_type is string) {
		return "\<input_type=\"text\" value={question.answer_id.name} onChange={e =\> handleChange(e)} /\>";
	} 
	
	return "sum ting wong";
} 