assert = require 'assert'
util = require 'util'
stringify = JSON.stringify

{Buffer} = require './emitter'

log = console.log
_log = ->
dbg = (x...) ->
    _log x...
    x

#
# Symbol tables are local to top level constructs such as functions,
# requires, message and appliesIf.
#
class SystemAttrs
    $APPID: undefined
    $USER: undefined
    $MYSIDE: undefined
    $MAJORVERSION: undefined
    MINORVERSION: undefined
    $TRIGGER: undefined
    $N: undefined
    $STATE: undefined

class SymbolTable extends SystemAttrs

symbolTable = new SymbolTable()

attrTable = {}
functionTable = (require "./functions").funs

class SyntaxNode
    constructor: (@lineno) ->
        assert(@lineno?)

    msg: (lvl, s...) ->
        console.log "#{exports.filename}:#{@lineno}:#{lvl}:", s...

    error: (ex, s...) ->
        @msg 'error', ex, s
        _log "#{exports.filename}:#{@lineno}:error:#{ex}", s...
        _log util.inspect @, false, 10
        throw ex
                
    emit: (buf) ->
        assert buf?
        try
            @emitImpl(buf)
        catch ex
            @error ex
            log 'buffer', buf.buffer
            log 'line', buf.line
            throw ex
    #
    # These two methods are here to convert mark pascal list notation
    # into JSON. For most node types it's asumed the syntax element
    # will evaluate to a JSON construct and so we don't have to do
    # anything, but for literal strings we can convert the
    # name:vale:desc; syntax.
    # 
    #
    # If we hit a node where we know we definitely ought to have an mp
    # list we call this method which should pass the information down
    # the syntax tree and inform the leaf nodes that give the value to
    # the expression that they should be a list.
    # 
    isList: -> _log 'SyntaxNode.isList', @
    isObject: ->

#
# buf - output buffer
# m - build time path to module
# method - require or include
# mm - run time path to module
# 
emitImport = (buf, m, method, mm=m) ->
    _log 'including', m, mm
    # imp = require m
    # assert imp?
    # buf.putln '{'
    # buf.push()
    # for k, v of imp when k not in ['rules', 'sets', 'check']
    #     buf.putln k  #, ', '
    # buf.pop()
    # buf.putln "} = #{method} '#{mm}'"
    buf.putln "#{method} '#{mm}'"

class exports.RuleBase extends SyntaxNode
    includes: []
    functions: []
    rules: []
    sets: []

    constructor: (lineno, children) ->
        super(lineno)
        for n in children
            try
                n.dispatch @
            catch x
                @error x, n

    emitImpl: (buf) ->
        buf.putln "RuleBase = require('../rulebase')"
        buf.putln "{funs, rule, useRule, set, include} = rb = new RuleBase(module)"
        buf.blankLine()
        emitImport buf, './functions', 'include', '../functions'
        buf.blankLine()
        for l in [@includes, @functions, @rules, @sets]
            e.emit buf for e in l
            buf.blankLine()
        buf.putln "exports.attrs = #{stringify attrTable, null, '    '}"
        buf.putln 'exports.rules = rb.rules'
        buf.putln 'exports.sets = rb.sets'
        buf.putln 'exports.funs = rb.funs'
        buf.putln 'exports.check = rb.check'

#        buf.putln '{exports.rules, exports.sets, exports.funs, exports.check} = rb'

class TopLevel extends SyntaxNode
    constructor: (lineno) ->
        super(lineno)
        symbolTable = new SymbolTable()

class exports.OtherSide extends TopLevel
    constructor: (lineno, @stmt) -> super(lineno)
    dispatch: (rb) -> rb.otherSide = @
    emitImpl: (buf) ->
        buf.putln 'otherSide ->'
        buf.putln @stmt
        buf.blankLine()

class exports.OtherSideError extends TopLevel
    constructor: (lineno, @stmt) -> super(lineno)
    dispatch: (rb) -> rb.otherSideError = @
    emitImpl: (buf) ->
        buf.putln 'otherSideError ->'
        buf.putln @stmt
        buf.blankLine()

class exports.Include extends SyntaxNode
    constructor: (lineno, @filename) ->
        inc = require './rules/' + @filename
        functionTable[n] = f for n, f of inc.funs

        includeAttr = (n, c) ->
            if n in attrTable
                attrTable[n] += c
            else
                attrTable[n] = c
        includeAttr n, c for n, c of inc.attrs

        super(lineno)

    dispatch: (rb) -> rb.includes.push @
    emitImpl: (buf) ->
        emitImport buf, ('./rules/' + @filename), 'include', ('./' + @filename)

class exports.FuncDef extends TopLevel
    constructor: (lineno, @name, @params, @body) ->
        super(lineno)
        functionTable[@name] = @
        _log "FuncDef", @name, @params, @body

    dispatch: (rb) -> rb.functions.push @
    emitImpl: (buf) ->
        buf.putln 'funs.', @name, ' = ', @params, ' ->'
        buf.push()
        buf.putln @body
        buf.pop()
#        buf.putln "exports.#{@name} = #{@name}"
        buf.blankLine()
    isList: ->
        @body.isList()

    isObject: ->
        @body.isObject()

class exports.List extends SyntaxNode
    constructor: (lineno, @first, @rest, @sep=', ') ->
        super lineno
        assert @first?
        _log "List", @first, @rest

    emitImpl: (buf) ->
        _log 'List.emit'
        buf.put @first
        for p in @rest
            buf.put @sep, p

    isList: ->
        @first.isList()
        i.isList() for i in @rest

    isObject: ->
        @first.isObject()
        i.isObject() for i in @rest
                
class exports.FuncParams extends exports.List
    emitImpl: (buf) ->
        buf.put '('
        super buf
        buf.put ')'

class exports.ParamDecl extends SyntaxNode
    constructor: (lineno, @type, @name, @isArray) ->
        super lineno
        symbolTable[@name] = @
        _log (n for n of symbolTable)

    emitImpl: (buf) ->
        buf.put @name

class exports.RuleRequire extends TopLevel
    constructor: (lineno, @require) ->
        super(lineno)

    emitImpl: (buf) ->
        buf.putln "require: (env) -> "
        buf.push()
        buf.putln @require
        buf.pop()

class exports.RuleMessage extends TopLevel
    constructor: (lineno, @message) ->
        super(lineno)

    emitImpl: (buf) ->
        buf.putln "message: (env) -> "
        buf.push()
        buf.putln @message
        buf.pop()
            
class exports.Rule extends SyntaxNode
    constructor: (lineno, @name, @message, @require) ->
        super lineno
        assert  @name? and @message? and @require?
        _log 'Rule', @name, @message, @require

    dispatch: (rb) -> rb.rules.push @
    emitImpl: (buf) ->
        buf.putln "rule #{stringify @name},"
        buf.push()
        buf.put @message
        buf.put @require
        buf.pop()
        buf.blankLine()
        
class exports.Set extends SyntaxNode
    constructor: (lineno, @name, @appliesIf, @rules) -> super(lineno)
    dispatch: (rb) -> rb.sets.push @
    emitImpl: (buf) ->
        buf.putln "set #{stringify @name},"
        buf.push()                
        if @appliesIf
            buf.putln "appliesIf: (env) ->"
            buf.push()
            buf.putln @appliesIf
            buf.pop()
            buf.blankLine()                
        buf.putln r for r in @rules
        buf.pop()
        buf.blankLine()                

class exports.RuleRef extends SyntaxNode
    constructor: (lineno, @name, @env) ->
        super(lineno)
    emitImpl: (buf) ->
        buf.put "useRule #{stringify @name}"
        if  @env.length > 0
            buf.put ','
            buf.newline()
            buf.push()
            buf.putln "#{name}: '#{value}'" for {name, value} in @env
            buf.pop()
            buf.blankLine()                

class exports.StmtList extends SyntaxNode
    constructor: (lineno, @stmts) ->
        super(lineno)
        assert(@stmts)
        #
        # Remove possible empty trailing statment.
        #
        if not @stmts[@stmts.length - 1]?
            @stmts.pop()
    emitImpl: (buf) ->
        for s in @stmts
            buf.putln s
    isList: ->
        @stmts[@stmts.length - 1].isList()

    isObject: ->
        @stmts[@stmts.length - 1].isObject()

class exports.Literal extends SyntaxNode
    constructor: (lineno, @text) ->
        super(lineno)
        _log 'Literal', @text                
    emitImpl: (buf) ->
        buf.put @text

class exports.StringLiteral extends exports.Literal
    emitImpl: (buf) ->
        if @text in ['', ' '] or isNaN +@text
            buf.put (stringify @text)
        else
            buf.put +@text
    #
    # Split a string by ; keeping only the bits that aren't ;s.
    # 
    # toArrayImp = (l) ->
    #     #        (i.replace /^\s*|\s*$/, '') for i in l.match /([^;]*)/g by 2
    #     l

    splitBySemi = (l) ->
        (i.replace /^\s*|\s*$/, '') for i in l.match /([^;]*)/g by 2

    toArrayImp = (l) ->
        o = {}
        for e in splitBySemi l
            o[e] = null
        stringify o

    emitList: (buf) ->
        result = toArrayImp @text #, null, idt
        _log 'StringLiteral.emitList', result
        buf.put result

    isList: ->
        _log 'StringLiteral.isList:', @text
        @emitImpl = @emitList
    #
    # And the same for key:value:desc.
    # 
    toObject: (buf) ->
        _log 'toObject enter'
        if @text.match /^{.*}$/
            _log 'StringLitteral.toObject', @text
            @text = @text.slice(1, -1)
            _log 'StringLitteral.toObject', @text
            buf.put new exports.Function @lineno, 'getList', new StringLiteral @lineno, @text
            return
        r = {}
        for i in splitBySemi @text
            try
                [_, k, v, d] = i.match /([^:]*):([^:]*):([^;]*);?/
                r[k] = value: v, description: d
            catch e
                @error e, "StringLiteral.toObject:#{@lineno}: failed for:", i
        buf.put stringify r #, null, idt

    emitObject: (buf) ->
        @toObject buf

    isObject: ->
        _log 'StringLiteral.isObject', @text
        @emitImpl = @emitObject

class exports.Undefined extends SyntaxNode
    emitImpl: (buf) ->
        buf.put 'undefined'

class exports.Declaration extends SyntaxNode
    constructor: (lineno, @name, @isArray, @init) ->
        super(lineno)
        _log "Declaration", @name, @isArray, @init
        symbolTable[@name] = @
        @init?.isList() if @isArray
    emitImpl: (buf) ->
        _log 'Declaration.emit'
        buf.put "#{@name} = "
        if @init?
            buf.put @init
        else
            buf.put (if @isArray? then '[]' else 'undefined')

    isList: ->
        log 'Declaration.isList', @init
        @init?.isList()
    isObject: ->
        log 'Declaration.isObject', @init
        @init?.isObject()

class exports.Function extends SyntaxNode
    #
    # Assert the cardinality of a function call.
    # 
    checkArgs = (args, n) ->
        switch n
            when 0
                assert not (args?.first? or args?.rest?), 'bad builtin'
            when 1
                assert args?.first? and not args?.rest?.length, 'bad builtin'
            else
                assert args?.first? and args?.rest[n - 2]? and
                    not args?.rest[n - 1]?, 'bad builtin'

    listProp = (buf, args, prop) ->
        checkArgs args, 2
        buf.put '@GetListProperty ', args.first, ', ', args.rest[0], ", '#{prop}'"
        
    listMember = (buf, args) -> buf.put args.first, '[', args.rest[0], ']'
    #
    # The child of a Function node is a ParamList. For certain
    # functions we know that one or more params must be a special.
    #
    # listArgs takes an array of integers denoting the args of a
    # function that are lists and generates a function that will check
    # this.
    # 
    specialArgs = (method, args...) ->
        (paramList) ->
            _log 'specialArgs', method, paramList.first
            for a in args
                if a == 1 then paramList.first[method]()
                else paramList.rest[a - 2][method]()
    #
    # Built in functions translated directly to coffee constructs.
    # 
    builtIns =
        Date:
            impl: (buf, args) ->
                #
                # mp date function takes day/month/year. We want
                # year/month/day. Also we need to convert the result to a
                # number to allow comparisons to work. So convert Date to
                # DateVal which constructs a date and then returns millis
                # since 1970.
                # 
                checkArgs args, 3
                buf.put '(@DateVal ', args.rest[1], ', ', args.rest[0], ', ', args.first, ')'
            
        FieldElement:
            impl: (buf, args) ->
                checkArgs args, 2
                buf.put '@[', args.first, ']'
                if args.rest[0]?.text != '0'
                    buf.put '[', args.rest, ']'

        GetEnv:
            impl: (buf, args) ->
                checkArgs args, 1
                buf.put 'env[', args.first, ']'

        HaveField:
            impl: (buf, args) ->
                checkArgs args, 1
                buf.put '@[', args, ']?'

        # ListContains:
        #     impl: (buf, args) ->
        #         checkArgs args, 2
        #         # buf.put '(', args.rest[0], ' in (', args.first, ' or []))'
        #         buf.put '(', args.first, '.indexOf ', args.rest[0], ') != -1'
        #     typeF: specialArgs 'isList', 1

        # ListContains:
        #     impl: (buf, args) ->
        #         checkArgs args, 2
        #         # buf.put '(', args.rest[0], ' in (', args.first, ' or []))'
        #         buf.put '(', args.first, '? and ', args.rest[0], ' of ', args.first, ')'
        #         # buf.put '(', args.first, '.indexOf ', args.rest[0], ') != -1'
        #     typeF: specialArgs 'isList', 1
        
        ListData:
            impl: (buf, args) -> listProp buf, args, 'data'
            typeF: specialArgs 'isObject', 1

        ListDescription:
            impl: (buf, args) -> listProp buf, args, 'description'
            typeF: specialArgs 'isObject', 1

        ListElement:
            impl: (buf, args) ->
                checkArgs args, 2
                listMember buf, args
            typeF: specialArgs 'isList', 1
            

        # GetListProperty: (buf, args) ->
        #     checkArgs args, 3
        #     listMember buf, args
        #     buf.put '?[', args.rest[1], ']'

        ListParticipant:
            impl: (buf, args) -> listProp buf, args, 'participant'
            typeF: specialArgs 'isObject', 1
            
        ListSize:
            impl: (buf, args) ->
                checkArgs args, 1
                buf.put args.first, '?.length'
            typeF: specialArgs 'isList', 1

        SubString:
            impl: (buf, args) ->
                checkArgs args, 3
                buf.put '(', args.first, ')?.substr(', args.rest[0], ', ', args.rest[1], ')'

        Max:
            impl: (buf, args) ->
                checkArgs args, 2
                buf.put 'Math.max ', args.first, ', ', args.rest[0]

        # ServerFunction: (buf, args) ->
        #     buf.put args.first, args.rest

    
    constructor: (lineno, @name, @args) ->
        super(lineno)
        _log('Function ', @name, @args)
        if not (@name of builtIns or @name of functionTable)
            @msg 'warning', "function #{name} not defined."

        bi = builtIns[@name]
        if @args? and bi?
            bi.typeF? @args
            # log 'have args', @args
            # for a of @args
            #     log 'arg', a
            #     bi.typeF a
        
    emitImpl: (buf) ->
        if (bi = builtIns[@name])? 
            bi.impl buf, @args
        else
            buf.put '@', @name, '(', @args, ')'

    isList: ->
        #
        # Lookup the defintion of the function and tell it, must return a list.
        #
        _log 'Function.isList'
        if @name of builtIns
            return
        functionTable[@name].isList()

    isObject: ->
        #
        # Lookup the defintion of the function and tell it, must return a list.
        #
        _log 'Function.isObject'
        if @name of builtIns
            return
        functionTable[@name].isObject()
        

class exports.ParamList extends exports.List

class exports.UnaryOp extends SyntaxNode
    @operators: {}

    constructor: (lineno, @op, @rhs) ->
        super(lineno)
        _log 'UnaryOp', @op, @rhs                
    emitImpl: (buf) -> buf.put "#{@op} ", @rhs

class exports.BinaryOp extends SyntaxNode
    operators:
        ':=': '='
        '=': '=='
        '<>': '!='

    breaks: ['+', '-', '*', 'and', 'AND', 'not', 'NOT', 'or', 'OR', 'is']

    mapOp: (op) -> @operators[op] ? op
    constructor: (lineno, @op, @rhs, what) ->
        super(lineno)
        _log 'BinaryOp', (util.inspect @, false, 10), what
    emitImpl: (buf) ->
        _log 'BinaryOp.emit', (util.inspect @, false, 10)
        buf.put " #{@mapOp @op} "
        buf.break() if @op in @breaks
        buf.put @rhs

class exports.BinaryExpr extends SyntaxNode
    constructor: (lineno, @lhs, @rhs, what) ->
        super(lineno)
        _log 'BinaryEpr', (util.inspect @, false, 10), what
        assert @lhs and @rhs, "BinaryOp buggered: lhs: #{lhs}, rhs: #{rhs}."
    emitImpl: (buf) ->
        _log 'BinaryEpr.emit', (util.inspect @, false, 10)
        buf.put @lhs, @rhs

class exports.Attribute extends SyntaxNode
    constructor: (lineno, @name) ->
        super(lineno)
        _log 'Attribute:', @name
        if @name of attrTable
            attrTable[@name] += 1
        else
            attrTable[@name] = 1
    emitImpl: (buf) ->
        _log 'Attribute.emit', @name
        if /^[_a-zA-Z][_a-zA-Z0-9]*$/.exec @name
            buf.put "@#{@name}"
        else
            buf.put "@[#{stringify @name}]"

class exports.IfStmt extends SyntaxNode
    constructor: (lineno, @condition, @trueBranch, @falseBranch) ->
        super(lineno)
    emitImpl: (buf) ->
        buf.putln "if ", @condition
        buf.push()
        buf.putln @trueBranch
        buf.pop()
        if @falseBranch
            buf.putln "else"
            buf.push()
            buf.putln @falseBranch
            buf.pop()
    isList: ->
        @trueBranch.isList()
        @falseBranch?.isList()

    isObject: ->
        @trueBranch.isObject()
        @falseBranch?.isObject()

class exports.SwitchStmt extends SyntaxNode
    constructor: (lineno, @expr, @cases, @def) ->
        super(lineno)
    emitImpl: (buf) ->
        buf.putln "switch ",  @expr
        buf.push()
        buf.put c for c in @cases
        buf.put @def if @def?
        buf.pop()

    isList: ->
        c.isList() for c in @cases
        @def?.isList()
    isObject: ->
        c.isObject() for c in @cases
        @def?.isObject()

class exports.ExpressionCase extends SyntaxNode
    constructor: (lineno, @labels, @stmts) ->
        super(lineno)

    emitImpl: (buf) ->
        tmp = new Buffer()
        tmp.put @stmts
        if tmp.lines.length > 1
            buf.putln "when ", @labels
            buf.push()
            buf.put @stmts
            buf.pop()
        else
            buf.putln "when ", @labels, ' then ', @stmts

    isList: -> @stmts.isList()
    isObject: -> @stmts.isObject()

class exports.LabelList extends exports.List

class exports.DefaultClause extends SyntaxNode
    constructor: (lineno, @stmts) -> assert(@stmts)
    emitImpl: (buf) ->
        tmp = new Buffer()
        tmp.put @stmts
        if tmp.lines.length > 1
            buf.putln "else"
            buf.push()
            buf.putln @stmts
            buf.pop()
        else
            buf.putln "else ", @stmts

    isList: -> @stmts.isList()
    isObject: -> @stmts.isObject()
            
class exports.VariableRef extends SyntaxNode
    constructor: (lineno, @name, @arraryIndex) ->
        super(lineno)
        assert not @arrayIndex?, 'todo'
        #        console.log exports.parser.parser
        if not @name of symbolTable
            @error 'undefined', "#{@name} undefined in #{n for n of symbolTable}"
    emitImpl: (buf) -> buf.put @name
    isList: ->
        _log 'VariableRef.isList', @name
        symbolTable[@name]?.isList()
    isObject: ->
        _log 'VariableRef.isObject', @name
        symbolTable[@name]?.isObject()

class exports.Parens extends SyntaxNode
    constructor: (lineno, @stmts) -> super(lineno)
    emitImpl:    (buf)            -> buf.put '(', @stmts, ')'
    isList:                       -> @stmts.isList()
    isObject:                     -> @stmts.isObject()

class exports.WhileStmt extends SyntaxNode
    constructor: (lineno, @cond, @body) ->
        super(lineno)

    emitImpl: (buf) ->
        buf.putln 'while ', @cond
        buf.push()
        buf.putln @body
        buf.pop()

class exports.ForStmt extends SyntaxNode
    constructor: (lineno, @init, @cond, @step, @body) ->
        super(lineno)
        _log 'Here I am in ctor'

    emitImpl: (buf) ->
        _log 'ForStmt.emitImpl'
        buf.putln @init if @init?
        if @cond?
            buf.putln 'while ', @cond
        else
            buf.putln 'while true'
        buf.push()
        buf.putln @body
        buf.putln @step if @step?
        buf.pop()
