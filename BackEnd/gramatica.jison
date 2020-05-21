/**
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
\"([^\\]|\\.)*\"				{ yytext = yytext.substr(1,yyleng-2); return 'LITERAL_STRING'; }
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
	: compilationunit EOF{return {root: $1}}
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
	: primitivetype
	| classorinterfacetype
;

primitivetype
	: INT 
	| CHAR 
	| STRING
	| BOOLEAN 
	| DOUBLE 
;

classorinterfacetype
	: name 
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
	| methoddeclaration 
	| constructordeclaration 
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
	| IDENTIFICADOR IGUAL expression {$$ = $1}
	
;

//Declaración de métodos
methoddeclaration
	: type IDENTIFICADOR PAR_APERTURA formalparameterlist PAR_CIERRE methodbody 
	| VOID IDENTIFICADOR PAR_APERTURA formalparameterlist PAR_CIERRE methodbody 
;

formalparameterlist
	: formalparameter
	| formalparameterlist COMA formalparameter
	| %empty
;

formalparameter
	: type IDENTIFICADOR
;

methodbody
	: block
	| PUNTO_COMA
;

// Declaración de constructor
constructordeclaration
	: IDENTIFICADOR PAR_APERTURA formalparameterlist PAR_CIERRE constructorbody
;

constructorbody
	: LLAVE_APERTURA blockstatements LLAVE_CIERRE
	| LLAVE_APERTURA LLAVE_CIERRE
;

// Bloques de instrucciones
block
	: LLAVE_APERTURA blockstatements LLAVE_CIERRE
	| LLAVE_APERTURA LLAVE_CIERRE
;

blockstatements
	: blockstatement
	| blockstatements blockstatement
;

blockstatement
	: localvariabledeclaration
	| statement
	| %empty
;

localvariabledeclaration
	: type variabledeclarators PUNTO_COMA
	| variabledeclarators PUNTO_COMA
;

statement
	: statementwithouttrailingsubstatement
	| labeledstatement
	| ifthenstatement
	| ifthenelsestatement
	| whilestatement
	| forstatement
	| printstatement
;

printstatement
	: IMPRIMIR PAR_APERTURA expressionlistprint PAR_CIERRE PUNTO_COMA
	| IMPRIMIR_L PAR_APERTURA expressionlistprint PAR_CIERRE PUNTO_COMA
	| IMPRIMIR_L PAR_APERTURA PAR_CIERRE PUNTO_COMA
;

expressionlistprint
	:expressionlist SUMA expression
	|expression
;
statementnoshortif
	: statementwithouttrailingsubstatement
	| labeledstatementnoshortif
	| ifthenelsestatementnoshortif
	| whilestatementnoshortif
	| forstatementnoshortif
	| variabledeclarators PUNTO_COMA
	| printstatement
;

statementwithouttrailingsubstatement
	: block
	| expressionstatement
	| switchstatement
	| dostatement
	| breakstatement
	| continuestatement
	| returnstatement
	| printstatement
;

labeledstatement
	: IDENTIFICADOR DOS_PUNTOS statement
;

labeledstatementnoshortif
	: IDENTIFICADOR DOS_PUNTOS statementnoshortif
;

expressionstatement
	: statementexpression PUNTO_COMA
;

statementexpression
	: postincrementexpression
	| postdecrementexpression
	| methodinvocation
	| classinstancecreationexpression {$$ = $1}
;

ifthenstatement
	: IF PAR_APERTURA expression PAR_CIERRE statement
;

ifthenelsestatement
	:IF PAR_APERTURA expression PAR_CIERRE block ELSE elseifblocks
;

ifthenelsestatementnoshortif
	: IF PAR_APERTURA expression PAR_CIERRE statementnoshortif elseifblock
;

elseifblocks
	: elseifblocks elseifblock
	| elseifblock
;

elseifblock
	: ELSE IF PAR_APERTURA expression PAR_CIERRE block 
	| ELSE block
	| %empty
;

switchstatement
	: SWITCH PAR_APERTURA expression PAR_CIERRE switchblock
;

switchblock
	: LLAVE_APERTURA switchblockstatementgroups switchlabels LLAVE_CIERRE
;

switchblockstatementgroups
	: switchblockstatementgroup
	| switchblockstatementgroups switchblockstatementgroup
	| %empty
;

switchblockstatementgroup
	: switchlabels blockstatements
;

switchlabels
	: switchlabel
	| switchlabels switchlabel
	| %empty
;

switchlabel
	: CASE expression DOS_PUNTOS
	| DEFAULT DOS_PUNTOS
;

whilestatement
	: WHILE PAR_APERTURA expression PAR_CIERRE statement
;

whilestatementnoshortif
	: WHILE PAR_APERTURA expression PAR_CIERRE statementnoshortif
;

dostatement
	: DO statement WHILE PAR_APERTURA expression PAR_CIERRE PUNTO_COMA
;

forstatement 
	: FOR PAR_APERTURA forinit PUNTO_COMA expression PUNTO_COMA forupdate PAR_CIERRE statement
;

forstatementnoshortif
	: FOR PAR_APERTURA forinit PUNTO_COMA expression PUNTO_COMA forupdate PAR_CIERRE statementnoshortif
;

forinit
	: name IGUAL assignmentexpression
	| type variabledeclarators
;

forupdate
	: IDENTIFICADOR SUMA SUMA
	| IDENTIFICADOR RESTA RESTA
;

statementexpressionlist
	: statementexpression
	| statementexpressionlist COMA statementexpression
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
	| THIS {$$=$1}
	| PAR_APERTURA expression  PAR_CIERRE {$$=$2}
	| classinstancecreationexpression {$$=$1}
	| fieldaccess {$$=$1}
	| methodinvocation {$$=$1}
;

classinstancecreationexpression
	: NEW IDENTIFICADOR PAR_APERTURA argumentlist PAR_CIERRE {$$= {operacion: $1, id: $2, argumentos:[$4] }}
;

argumentlist
	: expression{$$=[$1]}
	| argumentlist COMA expression {$1.push($3), $$=$1}
	| %empty
;

fieldaccess
	: primary PUNTO	IDENTIFICADOR {$$={clase:"acceso_atributo", atributo: $3}}
;

methodinvocation
	: IDENTIFICADOR PAR_APERTURA argumentlist PAR_CIERRE {$$ = {clase: "metodo", id: $1, argumentos: $4 }}
	| primary PUNTO IDENTIFICADOR PAR_APERTURA argumentlist PAR_CIERRE {$$ = {clase: "metodo", id: $3, argumentos: $5 }}
;

postincrementexpression
	: IDENTIFICADOR SUMA SUMA {$$={operador:"+", operador:[$1,"1"]}}
;

postdecrementexpression
	: IDENTIFICADOR DECREMENTO {$$={operador:"-", operador:[$1,"1"]}}
;

unaryexpression 
	: RESTA expression {$$={operador: $1, operando: [$2]}}
	| unaryexpressionnotplusminus {$$ = $1}
	| literal {$$=$1}
;

unaryexpressionnotplusminus
	: postincrementexpression {$$ = $1}
	| postdecrementexpression {$$ = $1}
	| NOT unaryexpression {$$={operador: $1, operando: [$2]}}
	| PAR_APERTURA expression PAR_CIERRE {$$=$2}
;

multiplicativeexpression
	: unaryexpression {$$=$1}
	| multiplicativeexpression MULTIPLICACION unaryexpression {$$={operador: $2, operandos:[$1,$2]}}
	| multiplicativeexpression DIVISION unaryexpression {$$={operador: $2, operandos:[$1,$2]}}
	| multiplicativeexpression MODULO unaryexpression {$$={operador: $2, operandos:[$1,$2]}}
	| multiplicativeexpression POTENCIA unaryexpression {$$={operador: $2, operandos:[$1,$2]}}
;

additiveexpression
	: multiplicativeexpression {$$=$1}
	| additiveexpression SUMA multiplicativeexpression {$$={operador: $2, operandos:[$1,$2]}}
	| additiveexpression RESTA multiplicativeexpression {$$={operador: $2, operandos:[$1,$2]}}
;

relationalexpression
	: additiveexpression {$$=$1}
	| relationalexpression MENOR_QUE additiveexpression{$$={operador: $2, operandos:[$1,$2]}}
	| relationalexpression MAYOR_QUE additiveexpression {$$={operador: $2, operandos:[$1,$2]}}
	| relationalexpression MENOR_IGUAL additiveexpression {$$={operador: $2, operandos:[$1,$2]}}
	| relationalexpression MAYOR_IGUAL	additiveexpression {$$={operador: $2, operandos:[$1,$2]}}
;

equalityexpression
	: relationalexpression {$$ = $1}
	| equalityexpression IGUALDAD relationalexpression {$$={operador: $2, operandos:[$1,$2]}}
	| equalityexpression DISTINTO relationalexpression {$$={operador: $2, operandos:[$1,$2]}}
;

conditionalandexpression
	: equalityexpression {$$ = $1}
	| conditionalandexpression AND equalityexpression {$$={operador: $2, operandos:[$1,$3]}}
;

conditionalorexpression
	: conditionalandexpression { $$= $1}
	| conditionalorexpression OR  conditionalandexpression { $$= {operador: $2, operandos: [$1,$3]}}
;

assignmentexpression
	: conditionalorexpression { $$= $1}
;

expression
	: assignmentexpression { $$= $1}
;
