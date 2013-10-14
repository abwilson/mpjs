n = require './nodes.js'
#
# A grammar handler to produce coffeescript from mark pascal.
#


notNull = (x) ->
    x? and x.length

class exports.ToMP
    constructor: (@target) ->

    topLevelStmtList: (lineno, stmtList) ->
        @target.result = stmtList

    ruleFile: (lineno, list) ->
        @target.result = new n.RuleBase(lineno, list)

    include: (lineno, name) ->
        new n.Include(lineno, name)

    funcDef: (lineno, name, params, body) ->
        new n.FuncDef(lineno, name, params, body)

    funcParams: (lineno, first, rest) ->
        new n.FuncParams(lineno, first, rest)

    paramDecl: (lineno, type, name, isArray) ->
        new n.ParamDecl(lineno, type, name, isArray) 

    ruleDef: (lineno, name, msg, require) ->
        new n.Rule(lineno, name, msg, require)

    message: (lineno, expr) ->
        new n.RuleProperty(lineno, 'message', expr)

    require: (lineno, expr) ->
        new n.RuleProperty(lineno, 'require', expr)

    setDef: (lineno, name, appliesIf, rules) ->
        new n.Set(lineno, name, appliesIf, rules)
        
    ruleRef: (lineno, name, env) ->
        new n.RuleRef(lineno, name, env)        

    otherSide: (lineno, expr) ->
        new n.OtherSide(lineno, expr)

    otherSideError: (lineno, expr) ->
        new n.OtherSideError(lineno, expr)

    declaration: (lineno, name, isArray, initialiser) ->
        new n.Declaration(lineno, name, isArray, initialiser)

    ifStmt: (lineno, condition, trueBranch, falseBranch) ->
        new n.IfStmt(lineno, condition, trueBranch, falseBranch)

    whileStmt: (lineno, condition, body) ->
        new n.WhileStmt(lineno, condition, body)

    forStmt: (lineno, initialiser, condition, step, body) ->
        new n.ForStmt(lineno, initialiser, condition, step, body)

    switchStmt: (lineno, expr, cases, def) ->
        new n.SwitchStmt(lineno, expr, cases, def)
                
    expressionCase: (lineno, labels, expr) ->
        new n.ExpressionCase(lineno, labels, expr)

    labelList: (lineno, head, tail) ->
        new n.List(lineno, head, tail)

    defaultClause: (lineno, expr) ->
        new n.DefaultClause(lineno, expr)

    binaryNode: (lineno, lhs, rhs, type) ->
        if rhs? and rhs.length
            new n.BinaryExpr(lineno, lhs, rhs, type)
        else
            lhs
        
                
