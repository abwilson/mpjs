%{
    n = require('./nodes.js');
    mpjs = require('./mpjs.js');

    var log = console.log;
    var emit = console.log;
    log = function(){}

    var is = function(x) { return x && x.length; }
%}

%start ruleFile
%ebnf
%%

ruleFile: stmtList -> mpjs.result = $1
     | (funcDef | ruleDef | setDef | include | otherSide | otherSideError)* -> mpjs.result = new n.RuleBase(yylineno, $1)
;

include: includeKW line ->  new n.Include(yylineno, $2)
;

funcDef: functionKW identifier '(' funcParams? ')' funcBody -> new n.FuncDef(yylineno, $2, $4, $6)
;

funcParams: paramDecl trailingParam* -> new n.FuncParams(yylineno, $1, $2)
;

paramDecl: type identifier '[]'? -> new n.ParamDecl(yylineno, $1, $2, $3)
;

trailingParam: ';' paramDecl -> $2
;

funcBody: '{' stmtList '}' -> $2
;

ruleDef: ruleKW line '{' ruleBody  '}' -> new n.Rule(yylineno, $2, $4.message, $4.require)
;

stmtProp: stmtList newLine              -> $1
             | blockOpen stmtList blockClose -> $2
;

ruleBody: message require    -> { message: $1, require: $2 }
          | require message  -> { message: $2, require: $1 }
;

message: messageKW stmtProp -> new n.RuleMessage(yylineno, $2)
;

require: requireKW stmtProp -> new n.RuleRequire(yylineno, $2)
;

setDef: setKW line '{' appliesIf? ruleRef* '}' -> new n.Set(yylineno, $2, $4, $5)
;

appliesIf: appliesIfKW stmtProp -> $2
;

ruleRef: ruleKW line '{' ruleEnv* '}' -> new n.RuleRef(yylineno, $2, $4)
;

ruleEnv: ruleVarName line -> { name: $1, value: $2 }
;

otherSide: otherSideKW stmtProp -> new n.OtherSide(yylineno, $2)
;

otherSideError: otherSideErrorKW stmtProp -> new n.OtherSideError(yylineno, $2)
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

declaration: type identifier '[]'? initialisation? -> new n.Declaration(yylineno, $2, $3, $4)
;

type: boolean | datetime | duration | link | money | numeric | rate | string
;

initialisation: ':=' expression -> $2
;

compoundStmt: = begin stmtList end -> $2
;

controlStmt: ifStmt | whileStmt | forStmt | switchStmt
;

ifStmt: if expression then stmt elseClause? -> new n.IfStmt(yylineno, $2, $4, $5)
;

elseClause: else stmt -> $2
;

whileStmt: while expression do stmt -> new n.WhileStmt(yylineno, $2, $4)
;

forStmt: for forInit? ';' expression? ';' expression? do stmt -> new n.ForStmt(yylineno, $2, $4, $6, $8)
              ;

forInit: declaration | expression
;

switchStmt: switch expression expressionCase+ defaultClause? end -> new n.SwitchStmt(yylineno, $2, $3, $4)
;

expressionCase: case labelList ':' stmtList -> new n.ExpressionCase(yylineno, $2, $4)
                ;

labelList: stmt trailingLabel* -> new n.LabelList(yylineno, $1, $2)
           ;

trailingLabel: ',' stmt -> $2
;

defaultClause: default ':' stmtList -> new n.DefaultClause(yylineno, $3)
               ;

expression: simpleExpression assignmentStmt? {
    $$ = $2 ? new n.BinaryExpr(yylineno, $1, $2, 'expression') : $1 }
    ;

simpleExpression: logicalExpression predicate* -> is($2) ? new n.BinaryExpr(yylineno, $1, $2, 'simpleExpression') : $1
    ;

term: factor (multiplication | division)* -> is($2) ? new n.BinaryExpr(yylineno, $1, $2, 'term') : $1
    ;

logicalExpression: comparitand comparison* -> is($2) ? new n.BinaryExpr(yylineno, $1, $2, 'logicalExpression') : $1
    ;

comparitand: term (addition | subtraction)* -> is($2) ? new n.BinaryExpr(yylineno, $1, $2, 'comparitand') : $1
;

assignmentStmt: ':=' expression  -> new n.BinaryOp(yylineno, $1, $2, 'assignmentStmt')
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
