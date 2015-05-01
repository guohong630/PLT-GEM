grammar GEM;

fragment
GemLetter
    :   [a-zA-Z$_]
    ;

fragment
GemLetterOrDigit
    :   [a-zA-Z0-9$_]
    ;

BooleanLiteral: 'true' | 'false';
IntegerLiteral: DecimalNumeral;
fragment Digit: '0' | NonZeroDigit;
fragment NonZeroDigit: [1-9];
fragment Digits: Digit+;
fragment DecimalNumeral: '0' | NonZeroDigit Digits?;

FloatingPointLiteral: Digits '.' Digits+;

StringLiteral
 	: '\'' ( STRING_ESCAPE_SEQ | ~[\\\r\n'] )* '\''
 	| '"' ( STRING_ESCAPE_SEQ | ~[\\\r\n"] )* '"'
 	;
 	
Identifier
    :   GemLetter GemLetterOrDigit*
    ;
 	
fragment STRING_ESCAPE_SEQ
 	: '\\' .
 	;

WS : [ \t\r\n]+ -> skip ; // skip spaces, tabs, newlines

COMMENT
	: '/*' .*? '*/' -> skip
	;

LINE_COMMENT
	: '//' ~[\r\n]* -> skip
	;



compilationUnit: (variableDeclaration | methodDeclaration)* methodDeclaration EOF;

variableDeclaration
	: type variableDeclarators ';'
    ;

methodDeclaration
    :   (type | 'void') Identifier parameters
        (   methodBody
        |   ';'
        )
    ;

methodBody
    :   block
    ;

expression :   primary #primaryExpr
    |   expression '[' expression ']' #arrayExpr
    |   expression '(' expressionList? ')' #funcExpr
    |   'new' constructor #constructorExpr
    |	'input' StringLiteral #inputExpr
    |   ('+'|'-') expression #unaryExpr
    |   ('~'|'!') expression #unaryRelExpr
    |   expression ('*'|'/'|'%') expression #binTopExpr
    |   expression ('+'|'-') expression #binLowExpr
    |   expression ('<=' | '>=' | '>' | '<') expression #binRelExpr
    |   expression ('==' | '!=') expression #binEqExpr
    |   expression '&&' expression #binAndExpr
    |   expression '||' expression #binOrExpr
    |   <assoc=right> expression 
        (   '='
        |   '+='
        |   '-='
        |   '*='
        |   '/='
        |   '%='
        )
        expression #assignExpr
;


type
    :	eventType ('[' ']')*
    |   specialType ('[' ']')*
    |   primitiveType ('[' ']')*
    ;


constructor: unitConstructor
		   | battleConstructor
		   | eventType eventArguments eventBlock;

eventBlock: '{' blockStatement*
				nextStatement '}'
				;

unitConstructor: 'Unit' unitArguments
				 ;

unitArguments: '(' expression ',' expression ',' expression ',' expression ')';


battleConstructor: 'Battle' battleArguments
				 ;

battleArguments: '(' expression ',' expression ')';


//itemConstructor: 'Item' itemArguments
//				 ;
//
//itemArguments: '(' expression ',' expression ',' expression ',' expression ')';


arguments
    :   '(' expressionList? ')'
    ;

expressionList
    :   expression (',' expression)*
    ;

eventArguments
	:	'(' eventExpressionList ')'
	;

eventExpressionList
	:	expression ',' expression (',' expressionList)?
	;

block
    :   '{' blockStatement* '}'
    ;

blockStatement
    :   statement
    |   variableDeclaration
    ;

//localVariableDeclarationStatement
//    :    localVariableDeclaration ';'
//    ;
//
//localVariableDeclaration
//    :   type variableDeclarators
//    ;

variableDeclarators
    :   variableDeclarator (',' variableDeclarator)*
    ;

variableDeclarator
    :   variableDeclaratorId ('=' variableInitializer)?
    ;

variableDeclaratorId
    :   Identifier
    ;

variableInitializer
    :   arrayInitializer
    |   expression
    ;

arrayInitializer
    :   '{' (variableInitializer (',' variableInitializer)* (',')? )? '}'
    ;

statement	:   block	#bs
			|   'if' parExpression statement ('else' statement)?	#ifStatement
			|   'for' '(' forControl ')' statement	#forStatement
			|   'while' parExpression statement	#whileStatement
			|   'switch' parExpression '{' switchBlockStatementGroup* switchLabel* '}'	#switchStatement
			|   'return' expression? ';'	#returnStatement
			|	'print' expression ';'	#printStatement
			|   'break' ';'	#breakStatement
			|   'continue' ';'	#continueStatement
			|   ';'	#emptyStatement
			|   statementExpression ';'	#statementExpr
			;

nextStatement:
		'next' expression ';';

switchBlockStatementGroup
    :   switchLabel+ blockStatement+
    ;

switchLabel
    :   'case' expression ':'
    |   'default' ':'
    ;

parExpression
    :   '(' expression ')'
    ;
    
forControl
    :   forInit? ';' expression? ';' forUpdate?
    ;

forInit
    :   expressionList
    ;

forUpdate
    :   expressionList
    ;

statementExpression
    :   expression
    ;

eventType: 'Event';

specialType: 'Unit' | 'Battle'; 

primitiveType
	:   'boolean'
    |   'int'
    |   'double'
    |	'String'
    ;

parameters
	:	'(' parameterList? ')'
	;

parameterList
	:	parameter (',' parameter)*
	;

parameter
	:	type variableDeclaratorId
	;

primary
    :   '(' expression ')'
    |   Identifier
    |   literal
    ;

literal
    :   IntegerLiteral
    |   FloatingPointLiteral
    |   StringLiteral
    |   BooleanLiteral
    |   'null'
    ;

