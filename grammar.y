%{
    var n = require('./nodes.js');
    var mpjs = require('./mpjs.js');

    var log = console.log;
    var emit = console.log;
/*    var log = function(){} */

    var is = function(x) { 
        return x && x.length; 
    }

    var handler;
    exports.setHandler = function(x) { handler = x; }

    to_coffee = require('./to_coffee.js');
/*    console.log("to_mp = ", to_mp); */

    handler = new to_coffee.ToMP(mpjs);
/*    console.log("handler = ", handler); */
%}

%start file
%ebnf
%%

 /*
  * This is the top level production. A file can contain either just a
  * list of statements, or it's a file defining a rulebase.
  */
file: topLevelStmtList | ruleFile
;

topLevelStmtList: stmtList
-> handler.topLevelStmtList(yylineno, $1)
;

ruleFile: (funcDef 
| ruleDef
| setDef
| include
| otherSide
| otherSideError)*
-> handler.ruleFile(yylineno, $1)
;

include: includeKW line
-> handler.include(yylineno, $2)
;

funcDef: functionKW identifier '(' funcParams? ')' funcBody
-> handler.funcDef(yylineno, $2, $4, $6)
;

funcParams: paramDecl trailingParam*
-> handler.funcParams(yylineno, $1, $2)
;

paramDecl: type identifier '[]'?
-> handler.paramDecl(yylineno, $1, $2, $3)
;

trailingParam: ';' paramDecl -> $2
;

funcBody: '{' stmtList '}' -> $2
;

ruleDef:
  ruleKW line '{' message require  '}'
    -> handler.ruleDef(yylineno, $2, $4, $5)
| ruleKW line '{' require message  '}'
    -> handler.ruleDef(yylineno, $2, $5, $4)
;

/*
 * A statement property is a mark pascal expression used as a
 * property. It can be either a single line expression, or a multiple
 * lines enclosed in \\..//.
 */
stmtProp: stmtList newLine -> $1
| blockOpen stmtList blockClose -> $2
;

message: messageKW stmtProp
-> handler.message(yylineno, $2)
;

require: requireKW stmtProp
-> handler.require(yylineno, $2)
;

setDef: setKW line '{' appliesIf? ruleRef* '}'
-> handler.setDef(yylineno, $2, $4, $5)
;

appliesIf: appliesIfKW stmtProp -> $2
;

ruleRef: ruleKW line '{' ruleEnv* '}'
-> handler.ruleRef(yylineno, $2, $4)
;

ruleEnv: ruleVarName line -> { name: $1, value: $2 }
;

otherSide: otherSideKW stmtProp
-> handler.otherSide(yylineno, $2)
;

otherSideError: otherSideErrorKW stmtProp
-> handler.otherSideError(yylineno, $2)
;

stmtList: stmt trailingStmt* { 
    $2.unshift($1); $$ = new n.StmtList(yylineno, $2) }
;

trailingStmt: ';' stmt -> $2
;

stmt: 
| declaration
| compoundStmt
| controlStmt
| expression
;

declaration: type identifier '[]'? initialisation?
-> handler.declaration(yylineno, $2, $3, $4)
;

type: boolean | datetime | duration | link | money | numeric | rate | string
;

initialisation: ':=' expression -> $2
;

compoundStmt: = begin stmtList end -> $2
;

controlStmt: ifStmt | whileStmt | forStmt | switchStmt
;

ifStmt: if expression then stmt elseClause?
-> handler.ifStmt(yylineno, $2, $4, $5)
;

elseClause: else stmt -> $2
;

whileStmt: while expression do stmt
-> handler.whileStmt(yylineno, $2, $4)
;

forStmt: for forInit? ';' expression? ';' expression? do stmt
-> handler.forStmt(yylineno, $2, $4, $6, $8)
;

forInit: declaration | expression
;

switchStmt: switch expression expressionCase+ defaultClause? end
-> handler.switchStmt(yylineno, $2, $3, $4)
;

expressionCase: case labelList ':' stmtList
-> handler.expressionCase(yylineno, $2, $4)
;

labelList: stmt trailingLabel*
-> handler.labelList(yylineno, $1, $2)
;

trailingLabel: ',' stmt -> $2
;

defaultClause: default ':' stmtList
-> handler.defaultClause(yylineno, $3)
;

expression: simpleExpression assignmentStmt?
    -> $2 ? new n.BinaryExpr(yylineno, $1, $2, 'expression') : $1
;
/* -> handler.binaryNode(yylineno, $1, $2, 'epxression') */


simpleExpression: logicalExpression predicate*
-> is($2) ? new n.BinaryExpr(yylineno, $1, $2, 'simpleExpression') : $1
    ;

/* -> handler.binaryNode(yylineno, $1, $2, 'simpleEpxression') */
/* ; */


term: factor (multiplication | division)* -> is($2) ? new n.BinaryExpr(yylineno, $1, $2, 'term') : $1
    ;

logicalExpression: comparitand comparison* -> is($2) ? new n.BinaryExpr(yylineno, $1, $2, 'logicalExpression') : $1
    ;

comparitand: term (addition | subtraction)* -> is($2) ? new n.BinaryExpr(yylineno, $1, $2, 'comparitand') : $1
;

assignmentStmt: ':=' expression 
-> new n.BinaryOp(yylineno, $1, $2, 'assignmentStmt')
;

predicate: (and | or) logicalExpression -> new n.BinaryOp(yylineno, $1, $2, 'predicate')
           ;

comparison: comparitor comparitand -> new n.BinaryOp(yylineno, $1, $2, 'comparison')
    ;

multiplication: star factor  -> new n.BinaryOp(yylineno, $1, $2, 'multiplication')
    ;

division: '/' factor         -> new n.BinaryOp(yylineno, $1, $2, 'division')
    ;

addition: '+' term           -> new n.BinaryOp(yylineno, $1, $2, 'addition')
    ;

subtraction: '-' term        -> new n.BinaryOp(yylineno, $1, $2, 'subtraction')
    ;

factor: '(' stmtList ')' -> new n.Parens(yylineno, $2)
      | function
      | notFactor
      | negation
      | stringLiteral
      | attrValue
      | variableValue
      | (sysAttr | this) -> new n.VariableRef(yylineno, $1)
      | argument
      | (number | false | true)  -> new n.Literal(yylineno, $1)
      | null                     -> new n.Undefined(yylineno)
      | envvar
      ;

/* Built in functions with special implementations. */
/* FieldElement '(' stmt '0' ')' -> */
function: identifier '(' paramList? ')' -> new n.Function(yylineno, $1, $3)
;

paramList: stmt trailingParam* ->  new n.ParamList(yylineno, $1, $2)
;

trailingParam: ',' stmt -> $2
;

notFactor: not factor -> new n.UnaryOp(yylineno, $1, $2)
           ;

negation: '-' factor  -> new n.UnaryOp(yylineno, $1, $2)
    ;

stringLiteral: SQSTRINGLITERAL -> new n.StringLiteral(yylineno, $1)
| DQSTRINGLITERAL -> new n.StringLiteral(yylineno, $1)
             ;

attrValue: attrRef field* sizeExpression?
    ;

attrRef: attribute arrayIndex? -> new n.Attribute(yylineno, $1)
    ;

field: '.' attrRef
    ;

arrayIndex: '[' expression ']'
            ;

variableValue: variableRef field* arrayOp?
               ;

variableRef: identifier arrayIndex? -> new n.VariableRef(yylineno, $1, $2)
             ;

arrayOp: resizeExpression
         | sizeExpression
         | appendExpression
         | prependExpression
         | removeExpression
         | insertExpression
         ;

resizeExpression: '.' resize expression
    ;

sizeExpression: '.' size
    ;

appendExpression: '.' append expression
    ;

prependExpression: '.' prepend expression
    ;

removeExpression: '.' remove expression
    ;

insertExpression: '.' insert expression
    ;

%%
