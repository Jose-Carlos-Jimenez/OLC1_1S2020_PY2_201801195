°°°/**
* Ejemplo Intérprete Sencillo con Jison utilizando Nodejs en Ubuntu
*/

/* Definición Léxica */
%lex

%options case-sensitive

%%

\s+											// se ignoran espacios en blanco
"//".*										// comentario simple línea
[/][*][^*]*[*]+([^/*][^*]*[*]+)*[/]			// comentario multiple líneas

"--" 					return 'DECREMENTO';
"-"						return 'RESTA';
"!="					return 'DISTINTO';
"!"						return 'NOT';
\"([^\\\"]|\\.)*\"				{ yytext = yytext.substr(1,yyleng-2); return 'LITERAL_STRING'; }
"%"						return 'MODULO';
"&&"					return 'AND';
"("						return 'PAR_APERTURA';
"(*-1)" 				return 'MENOS_UNARIO';
[0-9]+("."[0-9]+)?\b  	return 'LITERAL_DOUBLE';
[0-9]+\b				return 'LITERAL_INT';
\'([^\\]|\\.?)\' 		return 'LITERAL_CHAR';
"System.out.println"	return 'IMPRIMIR_L';
"System.out.print"		return 'IMPRIMIR';
")" 					return 'PAR_CIERRE';
"*"						return 'MULTIPLICACION';
"."						return 'PUNTO';
","						return 'COMA';
"/"						return 'DIVISION';
":"						return 'DOS_PUNTOS';
";"						return 'PUNTO_COMA';
"\""					return 'COMILLA_DOBLE';
"\\"					return 'BARRA_INVERTIDA';
"\n"					return 'SALTO_LINEA';
"\r"					return 'RETORNO_CARROS';
"\t"					return 'TABULACION';
"^"						return 'POTENCIA';
"{"						return 'LLAVE_APERTURA';
"||"					return 'OR';
"}"						return 'LLAVE_CIERRE';
"++"					return 'INCREMENTO';
"+"						return 'SUMA';
"<="					return 'MENOR_IGUAL';
"=="					return 'IGUALDAD';
">="					return 'MAYOR_IGUAL';
">"						return 'MAYOR_QUE';
"<"						return 'MENOR_QUE';
"="						return 'IGUAL'
"boolean"				return 'BOOLEAN';
"break";				return 'BREAK';
"case"					return 'CASE';
"char"					return 'CHAR';
"class"					return 'CLASS';
"continue"				return 'CONTINUE';
"default"				return 'DEFAULT';
"do"					return 'DO';
"double"				return 'DOUBLE';
"else"					return 'ELSE';
"false"					return 'LITERAL_FALSE';
"for"					return 'FOR';
"if"					return 'IF';
"import"				return 'IMPORT';
"int"					return 'INT';
"new"					return 'NEW';
"return"				return 'RETURN';
"String"				return 'STRING';
"switch"				return 'SWITCH';
"this"					return 'THIS';
"true"					return 'LITERAL_TRUE';
"void"					return 'VOID';
"while"					return 'WHILE';
([a-zA-Z]|_)[a-zA-Z0-9_]*	return 'IDENTIFICADOR';
<<EOF>>				return 'EOF';


/lex

/* Asociación de operadores y precedencia */

%left 'MENOS_UNARIO'
%left 'NOT'
%left 'MENOR_QUE' 'MENOR_IGUAL' 'IGUALDAD' 'MAYOR_IGUAL' 'MAYOR_QUE'
%left 'MODULO'
%left 'SUMA' 'RESTA'
%left 'MULTIPLICACION' 'DIVISION'
%left 'POTENCIA'

%start goal

%% /* Definición de la gramática */

// Inicio de la gramática
goal
	: compilationunit EOF{return $1}
;

// Estructura léxica
literal
	:LITERAL_INT {$$ = $1}
	|LITERAL_DOUBLE {$$ = $1}
	|LITERAL_TRUE {$$ = $1}
	|LITERAL_FALSE {$$ = $1}
	|LITERAL_CHAR {$$ = $1}
	|LITERAL_STRING {$$ = $1}
	|methodinvocation {$$ = $1}
	|IDENTIFICADOR {$$ = $1}
;

// Tipos, valores y varibles
type
	: primitivetype {$$=$1}
	| classorinterfacetype{$$=$1}
;

primitivetype
	: INT {$$=$1}
	| CHAR {$$=$1}
	| STRING {$$=$1}
	| BOOLEAN {$$=$1}
	| DOUBLE {$$=$1}
;

classorinterfacetype
	: name {$$=$1}
;

// Nombres

name
	: IDENTIFICADOR {$$ = $1}
;

// Área de paquetes
compilationunit
	:importdeclarations typedeclarations {$$ = {imports:$1, clases: $2}}
;

importdeclarations
	:importdeclaration {$$ = [$1]}
	|importdeclarations importdeclaration {$1.push($2); $$ = $1} 
;

typedeclarations
	:typedeclaration {$$ = [$1]}
	|typedeclarations typedeclaration{$1.push($2); $$ = $1} 
;

importdeclaration
	:IMPORT name PUNTO_COMA {$$ = {clase: $2}}
	|IMPORT name PUNTO MULTIPLICACION PUNTO_COMA {$$ = {clase: $2}}
	| %empty
;

typedeclaration
	: classdeclaration {$$ = $1}
	| PUNTO_COMA
;

// Producciones para declarar clases
classdeclaration
	: CLASS IDENTIFICADOR LLAVE_APERTURA classbodydeclarations LLAVE_CIERRE 
	{$$ = {nombre: $2, cuerpo: $4} }
;

classbodydeclarations
	: classbodydeclaration {$$ = [$1]}
	| classbodydeclarations classbodydeclaration {$1.push($2) ;$$ = $1}
;

classbodydeclaration
	: fielddeclaration {$$ = $1}
	| methoddeclaration {$$= $1}
	| constructordeclaration {$$= $1}
	| %empty
;

// Producciones para la declaraciones
fielddeclaration
	: type variabledeclarators PUNTO_COMA {$$ = {operacion: "declaracion", tipo: $1, declaradas: $2}}
	| type variabledeclarators IGUAL expression PUNTO_COMA {$$ = {operacion: "declaracion_asign",tipo: $1, declaradas: $2, valor: $4}}
;

variabledeclarators
	: variabledeclarator {$$ = [$1]}
	| variabledeclarators COMA variabledeclarator {$1.push($3);$$ = $1}
;

variabledeclarator
	: IDENTIFICADOR {$$ = $1}
	| IDENTIFICADOR IGUAL expression {$$ = {variable:$1, valor: $3}}
	
;

//Declaración de métodos
methoddeclaration
	: type IDENTIFICADOR PAR_APERTURA formalparameterlist PAR_CIERRE methodbody
	{$$={metodo:$2, parametros:$4, cuerpo: $6}} 
	| VOID IDENTIFICADOR PAR_APERTURA formalparameterlist PAR_CIERRE methodbody 
	{$$={metodo:$2, parametros:$4, cuerpo: $6}}
;

formalparameterlist
	: formalparameter{$$=[$1]}
	| formalparameterlist COMA formalparameter {$1.push($3);$$=$1}
	| %empty
;

formalparameter
	: type IDENTIFICADOR {$$={tipo: $1, id: $2}}
;

methodbody
	: block {$$=$1}
	| PUNTO_COMA
;

// Declaración de constructor
constructordeclaration
	: IDENTIFICADOR PAR_APERTURA formalparameterlist PAR_CIERRE constructorbody 
	{ $$={constructor: $1, parametros: $3, instrucciones: $5}}
;

constructorbody
	: LLAVE_APERTURA blockstatements LLAVE_CIERRE {$$=$2}
	| LLAVE_APERTURA LLAVE_CIERRE {$$={}}
;

// Bloques de instrucciones
block
	: LLAVE_APERTURA blockstatements LLAVE_CIERRE {$$=$2}
	| LLAVE_APERTURA LLAVE_CIERRE {$$={}}
;

blockstatements
	: blockstatement {$$=[$1]}
	| blockstatements blockstatement {$1.push($2);$$=$1}
;

blockstatement
	: localvariabledeclaration {$$=$1}
	| statement {$$=$1}
	| %empty
;

localvariabledeclaration
	: type variabledeclarators PUNTO_COMA{$$={instruccion:"declaracion", declaradas: $2}}
	| variabledeclarators PUNTO_COMA {$$={instruccion:"asignacion", asignadas: $1}}
;

statement
	: statementwithouttrailingsubstatement {$$=$1}
	| ifthenstatement {$$=$1}
	| ifthenelsestatement {$$=$1}
	| whilestatement{$$=$1}
	| forstatement {$$=$1}
	| printstatement {$$=$1}
;

printstatement
	: IMPRIMIR PAR_APERTURA expression PAR_CIERRE PUNTO_COMA {$$={instruccion:$1, expresion: $3}}
	| IMPRIMIR_L PAR_APERTURA expression PAR_CIERRE PUNTO_COMA{$$={instruccion:$1, expresion: $3}}
	| IMPRIMIR_L PAR_APERTURA PAR_CIERRE PUNTO_COMA {$$={instruccion:$1, expresion: "\\n"}}
;

statementnoshortif
	: statementwithouttrailingsubstatement {$$=$1}
	| ifthenelsestatementnoshortif {$$=$1}
	| whilestatementnoshortif {$$=$1}
	| forstatementnoshortif {$$=$1}
	| variabledeclarators PUNTO_COMA {$$=$1}
	| printstatement {$$=$1}
;

statementwithouttrailingsubstatement
	: block {$$=$1}
	| expressionstatement {$$=$1}
	| switchstatement {$$=$1}
	| dostatement {$$=$1}
	| breakstatement {$$=$1}
	| continuestatement {$$=$1}
	| returnstatement {$$=$1}
	| printstatement {$$=$1}
;

expressionstatement
	: statementexpression PUNTO_COMA {$$=$1}
;

statementexpression
	: postincrementexpression {$$=$1}
	| postdecrementexpression {$$=$1}
	| methodinvocation {$$=$1}
;

ifthenstatement
	: IF PAR_APERTURA expression PAR_CIERRE statement
	{$$={instruccion:$1, condicion:$3, instrucciones:$5}}
;

ifthenelsestatement
	:IF PAR_APERTURA expression PAR_CIERRE block ELSE elseifblocks
	{$$={instruccion:$1, condicion:$3, instrucciones:$5, else:$2}}
;

ifthenelsestatementnoshortif
	: IF PAR_APERTURA expression PAR_CIERRE statementnoshortif elseifblock
	{$$={instruccion:$1, condicion:$3, instrucciones:$5, else:$2}} 
;

elseifblocks
	: elseifblock{$$=[$1]}
	| elseifblocks elseifblock {$1.push($2);$$=$1} 
	
;

elseifblock
	: ELSE IF PAR_APERTURA expression PAR_CIERRE block{$$ = {condicion: $3, instrucciones: $2}} 
	| ELSE block {$$ = {instrucciones: $2}}
	| %empty
;

switchstatement
	: SWITCH PAR_APERTURA expression PAR_CIERRE switchblock
	{ $$={instruccion:$1, variable: $3, instrucciones: $5}}
;

switchblock
	: LLAVE_APERTURA switchblockstatementgroups switchlabels LLAVE_CIERRE
	{$$={etiqueta:$2}}
;

switchblockstatementgroups
	: switchblockstatementgroup{$$=[$1]}
	| switchblockstatementgroups switchblockstatementgroup {$1.push($2), $$=$1}
	| %empty
;

switchblockstatementgroup
	: switchlabels blockstatements {$$={caso:$1, instrucciones: $2}}
;

switchlabels
	: switchlabel {$$=[$1]}
	| switchlabels switchlabel {$1.push($2), $$=$1}
	| %empty
;

switchlabel
	: CASE expression DOS_PUNTOS {$$=$2}
	| DEFAULT DOS_PUNTOS{$$="default"}
;

whilestatement
	: WHILE PAR_APERTURA expression PAR_CIERRE statement{$$={instruccion:$1, condicion: $3, instrucciones:$5}}
;

whilestatementnoshortif
	: WHILE PAR_APERTURA expression PAR_CIERRE statementnoshortif{$$= {instruccion:$1, condicion:$3, instrucciones:$5}}
;

dostatement
	: DO statement WHILE PAR_APERTURA expression PAR_CIERRE PUNTO_COMA {$$={instruccion:$1, instrucciones:$2, condicion:$2}}
;

forstatement 
	: FOR PAR_APERTURA forinit PUNTO_COMA expression PUNTO_COMA forupdate PAR_CIERRE statement
	{$$= {instruccion:$1, init:$3, condicion:$5, update:$7, instrucciones:$9 }}
;

forstatementnoshortif
	: FOR PAR_APERTURA forinit PUNTO_COMA expression PUNTO_COMA forupdate PAR_CIERRE statementnoshortif
	{$$= {instruccion:$1, init:$3, condicion:$5, update:$7, instrucciones:$9 }}
;

forinit
	: name IGUAL assignmentexpression {$$={nombre:$1, valor:$3}}
	| type variabledeclarators {$$ = {tipo:$1, variables:$2}}
;

forupdate
	: IDENTIFICADOR INCREMENTO {$$={operador:"++", operador:$1}}
	| IDENTIFICADOR DECREMENTO {$$={operador:"--", operador:$1}}
;

statementexpressionlist
	: statementexpression {$$=[$1]}
	| statementexpressionlist COMA statementexpression{$1.push($3),$$ = $1 } 
;

breakstatement
	: BREAK PUNTO_COMA {$$={instruccion: $1}}
;

continuestatement
	: CONTINUE PUNTO_COMA {$$ = {instruccion: $1}}
;

returnstatement
	: RETURN expression PUNTO_COMA {$$= {instruccion: $1, valor: $2}}
	| RETURN PUNTO_COMA {$$= {instruccion: $1, valor: "null"}}
;

// Producciones para expresion
primary
	: literal {$$=$1}
	| PAR_APERTURA expression  PAR_CIERRE {$$=$2}
	| methodinvocation {$$=$1}
;

argumentlist
	: expression{$$=[$1]}
	| argumentlist COMA expression {$1.push($3), $$=$1}
	| %empty
;

methodinvocation
	: IDENTIFICADOR PAR_APERTURA argumentlist PAR_CIERRE {$$ = {instruccion: "metodo", id: $1, argumentos: $3 }}
	| primary PUNTO IDENTIFICADOR PAR_APERTURA argumentlist PAR_CIERRE {$$ = {clase: "metodo", id: $3, argumentos: $5 }}
;

postincrementexpression
	: IDENTIFICADOR INCREMENTO {$$={operador:"++", operando:$1}}
;

postdecrementexpression
	: IDENTIFICADOR DECREMENTO {$$={operador:"--", operador:$1}}
;

unaryexpression 
	: RESTA expression {$$={operador: $1, operando: $2}}
	| unaryexpressionnotplusminus {$$ = $1}
	| literal {$$=$1}
;

unaryexpressionnotplusminus
	: postincrementexpression {$$ = $1}
	| postdecrementexpression {$$ = $1}
	| NOT unaryexpression {$$={operador: $1, operando: $2}}
	| PAR_APERTURA expression PAR_CIERRE {$$=$2}
;

multiplicativeexpression
	: unaryexpression {$$=$1}
	| multiplicativeexpression MULTIPLICACION unaryexpression {$$={operador: $2, operando_1:$1, operando_2:$3}}
	| multiplicativeexpression DIVISION unaryexpression {$$={operador: $2, operando_1:$1, operando_2:$3}}
	| multiplicativeexpression MODULO unaryexpression {$$={operador: $2, operando_1:$1, operando_2:$3}}
	| multiplicativeexpression POTENCIA unaryexpression {$$={operador: $2, operando_1:$1, operando_2:$3}}
;

additiveexpression
	: multiplicativeexpression {$$=$1}
	| additiveexpression SUMA multiplicativeexpression {$$={operador: $2, operando_1:$1, operando_2:$3}}
	| additiveexpression RESTA multiplicativeexpression {$$={operador: $2, operando_1:$1, operando_2:$3}}
;

relationalexpression
	: additiveexpression {$$=$1}
	| relationalexpression MENOR_QUE additiveexpression{$$={operador: $2, operando_1:$1, operando_2:$3}}
	| relationalexpression MAYOR_QUE additiveexpression {$$={operador: $2, operando_1:$1, operando_2:$3}}
	| relationalexpression MENOR_IGUAL additiveexpression {$$={operador: $2, operando_1:$1, operando_2:$3}}
	| relationalexpression MAYOR_IGUAL	additiveexpression {$$={operador: $2, operando_1:$1, operando_2:$3}}
;

equalityexpression
	: relationalexpression {$$ = $1}
	| equalityexpression IGUALDAD relationalexpression {$$={operador: $2, operando_1:$1, operando_2:$3}}
	| equalityexpression DISTINTO relationalexpression {$$={operador: $2, operando_1:$1, operando_2:$3}}
;

conditionalandexpression
	: equalityexpression {$$ = $1}
	| conditionalandexpression AND equalityexpression {$$={operador: $2, operando_1:$1, operando_2:$3}}
;

conditionalorexpression
	: conditionalandexpression { $$= $1}
	| conditionalorexpression OR  conditionalandexpression {$$={operador: $2, operando_1:$1, operando_2:$3}}
;

assignmentexpression
	: conditionalorexpression {$$= $1}
;

expression
	: assignmentexpression {$$=$1}
;
