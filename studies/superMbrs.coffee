class Super
    constructor: (@mbr) ->
    use: ->
        console.log @mbr

class Derived extends Super
    constructor: (@mbr) ->

x = new Derived 'hello'

x.use()

