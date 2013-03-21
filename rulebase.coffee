a = require('assert')
util = require('util')
log = console.log
#
# Marker to remind me to implement these.
# 
$APPID = ''
$USER = ''
$MYSIDE = ''
$MAJORVERSION = ''
$MINORVERSION = ''
$TRIGGER = ''
$N = ''
$STATE = ''

class Rule
    constructor: (@name, @require, @message=(env={}) -> "#{name} failed") ->
        #
        # Require must be a function.
        # 
        a.ok(@require.call?, "require must be callable")
        #
        # If message isn't a function wrap it in one.
        # 
        unless @message.call?
            msg = @message
            @message = -> msg
    #
    # Check that the required conditions are meet, if not return the
    # result of message.
    # 
    check: (deal, result, env={}) ->
        passed = @require.call deal, env
        # log "    Checking #{@name}", passed
        unless passed
            result[@name] = @message.call deal, env

class Set
    constructor: (@name, @appliesIf, @rules) ->
    check: (deal, result) ->
        # log 'Set.check', @name, (not @appliesIf?) or @appliesIf.call deal
        if (not @appliesIf?) or @appliesIf.call deal
            r deal, result for r in @rules

module.exports = class RuleBase
    funs: {}
    constructor: (@module, @rules={}, @sets=[]) -> # , @funs={}) ->
    #
    # Check a deal against a rulebase and reutrn a list of errors.
    # 
    check: (deal) =>
        @bind deal
        result = {}
        s.check deal, result for s in @sets
        result

    includeRule: (n, r) -> @rules[n] = r
    includeFun: (n, f) -> @funs[n] = f
    #
    # Syntactic sugar for defining RuleBases.
    #
    # Include the definitions from another RuleBase into this one.
    # 
    include: (filename) =>
        # console.log 'including', filename, ' from ', @module.id
        inc = @module.require(filename)
        @includeRule n, r for n, r of inc.rules if inc?.rules
        if inc?.sets
            # log "including #{filename} has sets: #{JSON.stringify inc.sets}"
            @sets.push s for s in inc.sets 
        @includeFun n, f for n, f of inc.funs if inc?.funs
        
        inc
    # 
    # Create a named rule and add it to the rulebase
    #
    rule: (n, properties={}) =>
        #
        # Otherwise we're making a new rule and properties are the
        # parameters.
        #
        @includeRule n, new Rule(n, properties.require, properties.message)
    #
    # Create a set and add it to the RuleBase.
    # 
    set: (name, properties, rules...) =>
        # log "set #{name}, #{properties}, #{rules}"
        #
        # If the second arg is an object with an applies if member
        # then the last arg is the list of rules.
        # 
        if properties.appliesIf?
            @sets.push new Set(name, properties.appliesIf, rules)
        else
            #
            # Otherwise we have no appliesIf condition and properties
            # is the first rule and rules (if defined) is the rest.
            # 
            # log "set: #{name}: props is rule", rules
            l = [properties]
            l.push r for r in rules
            @sets.push new Set(name, undefined, l)
    #
    # For use within a set definition to include a named rule in the
    # set with a given environment.
    # 
    useRule: (name, env={}) =>
        if r = @rules[name]
            #
            # Bind the rule's check method to the environment we've
            # been given.
            # 
            (deal, result) -> r.check deal, result, env
        else
            throw "undefined rule '#{name}' referenced in #{util.inspect @rules, false, 10}"
    #
    # Bind the functions in a rulebase to a deal.
    # 
    # bind: (deal) ->
    #     deal[k] = v for k, v of @funs
    bind: (d) -> d.__proto__ = @funs
