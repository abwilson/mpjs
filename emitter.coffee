assert = require 'assert'
util = require('util')

class Buffer
    constructor: ->
        @lines = []
        @idt = ''
        @line = ''
        @breakFlag = false
        
    push: -> @idt += '    '
    pop: -> @idt = @idt.slice 0, -4
    put: (args...) ->
        for a in args
            if util.isArray a
                @put a...
            else if a?
                if a?.emit
                    a.emit(@)
                else
                    @line += a
        @

    putln: (args...) ->
        @put args...
        @newline()
        @

    newline: ->
        if @line != ''
            @lines.push (@idt + @line) 
            @line = ''
        @

    blankLine: ->
        @lines.push ''
        @line = ''
        @

    lineLength: -> @line.length + @idt.length

    break: ->
        if @lineLength() > 70
            @newline()
        @

    buffer: -> @lines.join('\n')

exports.Buffer = Buffer

if false
    b = new Buffer

    class WithEmit
        emit: (b) -> b.put 'o out'
        
    o = new WithEmit()

    b.put 1, 2, 3, 4
    b.putln 5
    b.push()
    b.putln('heay').put(1, 2, 3).newline()
#    b.pop()
    b.putln 'hello'
    a = [ 1, o, 3 ]
    b.put 1, o, 3
    b.newline()
    b.putln 1, o, 3
    b.putln undefined
    b.putln a
    console.log b.buffer()
