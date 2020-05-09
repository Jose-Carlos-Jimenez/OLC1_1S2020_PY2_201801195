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

"-"						return 'RESTA';
"--" 					return 'DECREMENTO';
"!"						return 'NOT';
"!="					return 'DISTINTO';
\"[^\"]*\"				{ yytext = yytext.substr(1,yyleng-2); return 'LITERAL_STRING'; }
"%"						return 'MODULO';
"&&"					return 'AND';
"("						return 'PAR_APERTURA';
"(*-1)" 				return 'MENOS_UNARIO';
[0-9]+\b				return 'LITERAL_INT';
[0-9]+("."[0-9]+)?\b  	return 'LITERAL_DOUBLE';
'([a-zA-Z]|\\n|\\t|\\r|\\\\|\\\")' return 'LITERAL_CHAR';
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
"main"					return 'MAIN';
"new"					return 'NEW';
"return"				return 'RETURN';
"String"				return 'STRING';
"switch"				return 'SWITCH';
"System.out.println"	return 'IMPRIMIR_L';
"System.out.print"		return 'IMPRIMIR';
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
	: compilationunit EOF 
;

// Estructura léxica
literal
	:LITERAL_INT
	|LITERAL_DOUBLE
	|LITERAL_TRUE
	|LITERAL_FALSE
	|LITERAL_CHAR
	|LITERAL_STRING
	|IDENTIFICADOR
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
	: IDENTIFICADOR
	| name IDENTIFICADOR
;

// Área de paquetes
compilationunit
	:importdeclarations typedeclarations
; 

importdeclarations
	:importdeclaration 
	|importdeclarations importdeclaration
;

typedeclarations
	:typedeclaration
	|typedeclarations typedeclaration 
;

importdeclaration
	:IMPORT name PUNTO_COMA
	|IMPORT name PUNTO MULTIPLICACION PUNTO_COMA
;

typedeclaration
	: classdeclaration
	| PUNTO_COMA
;

// Producciones para declarar clases
classdeclaration
	: CLASS IDENTIFICADOR LLAVE_APERTURA classbodydeclarations LLAVE_CIERRE
;

classbodydeclarations
	: classbodydeclaration
	| classbodydeclarations classbodydeclaration
;

classbodydeclaration
	: fielddeclaration
	| methoddeclaration
	| constructordeclaration
	| %empty
;

// Producciones para la declaraciones
fielddeclaration
	: type variabledeclarators PUNTO_COMA
;

variabledeclarators
	: variabledeclarator
	| variabledeclarators COMA variabledeclarator
;

variabledeclarator
	: IDENTIFICADOR IGUAL expression
	| IDENTIFICADOR
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
	: type variabledeclarators PUNTO_COMA
	| statement
;

statement
	: statementwithouttrailingsubstatement
	| labeledstatement
	| ifthenstatement
	| ifthenelsestatement
	| whilestatement
	| forstatement
;

statementnoshortif
	: statementwithouttrailingsubstatement
	| labeledstatementnoshortif
	| ifthenelsestatementnoshortif
	| whilestatementnoshortif
	| forstatementnoshortif
;

statementwithouttrailingsubstatement
	: block
	| emptystatement
	| expressionstatement
	| switchstatement
	| dostatement
	| breakstatement
	| continuestatement
	| returnstatement
;

emptystatement
	: COMA
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
	| classinstancecreationexpression
;

ifthenstatement
	: IF PAR_APERTURA expression PAR_CIERRE statement
;

ifthenelsestatement
	:IF PAR_APERTURA expression PAR_CIERRE statementnoshortif ELSE statement
;

ifthenelsestatementnoshortif
	: IF PAR_APERTURA expression PAR_CIERRE statementnoshortif ELSE statementnoshortif
;

switchstatement
	: SWITCH PAR_APERTURA expression PAR_CIERRE switchblock
;

switchblock
	: LLAVE_APERTURA switchstatementgroups switchlabels LLAVE_CIERRE
;

switchblockstatementgroups
	: switchblockstatementgroup
	| switchblockstatementgroups switchblockstatementgroup
;

switchblockstatementgroup
	: switchlabels blockstatements
;

switchlabels
	: switchlabel
	| switchlabels switchlabel
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
	: statementexpressionlist
	| type variabledeclarators
;

forupdate
	: statementexpressionlist
;

statementexpressionlist
	: statementexpression
	| statementexpressionlist COMA statementexpression
;

breakstatement
	: BREAK PUNTO_COMA
;

continuestatement
	: CONTINUE PUNTO_COMA
;

returnstatement
	: RETURN expression PUNTO_COMA
	| RETURN PUNTO_COMA
;

// Producciones para expresion
primary
	: literal
	| THIS
	| PAR_APERTURA expression  PAR_CIERRE
	| classinstancecreationexpression
	| fieldaccess
	| methodinvocation
;

classinstancecreationexpression
	: NEW IDENTIFICADOR PAR_APERTURA argumentlist PAR_CIERRE
;

argumentlist
	: expression
	| argumentlist COMA expression
	| %empty
;

fieldaccess
	: primary PUNTO	IDENTIFICADOR
;

methodinvocation
	: name PAR_APERTURA argumentlist PAR_CIERRE
	| primary PUNTO IDENTIFICADOR PAR_APERTURA argumentlist PAR_CIERRE
;

postfixexpression:
	primary
	name
	postincrementexpression
	postdecrementexpression
;

postincrementexpression
	: postfixexpression SUMA SUMA
;

postdecrementexpression
	: postfixexpression DECREMENTO
;

unaryexpression 
	: SUMA unaryexpression
	| RESTA unaryexpression
	| unaryexpressionnotplusminus
	| literal
;

unaryexpressionnotplusminus
	: postfixexpression
	| NOT unaryexpression
;

multiplicativeexpression
	: unaryexpression
	| multiplicativeexpression MULTIPLICACION unaryexpression
	| multiplicativeexpression DIVISION unaryexpression
	| multiplicativeexpression MODULO unaryexpression
	| multiplicativeexpression POTENCIA unaryexpression
;

additiveexpression
	: multiplicativeexpression
	| additiveexpression SUMA multiplicativeexpression
	| additiveexpression RESTA multiplicativeexpression
;

relationalexpression
	: additiveexpression
	| relationalexpression MENOR_QUE additiveexpression
	| relationalexpression MAYOR_QUE additiveexpression
	| relationalexpression MENOR_IGUAL additiveexpression
	| relationalexpression MAYOR_IGUAL	additiveexpression
;

equalityexpression
	: relationalexpression
	| equalityexpression IGUALDAD relationalexpression
	| equalityexpression DISTINTO relationalexpression
;

conditionalandexpression
	: equalityexpression 
	| conditionalandexpression AND equalityexpression
;

conditionalorexpression
	: conditionalandexpression
	| conditionalorexpression OR  conditionalandexpression
;

assignmentexpression
	: conditionalorexpression
;

lefthandside
	: fielddeclaration
	| fieldaccess
;

expression
	: assignmentexpression
;
// Por aquí vamos
