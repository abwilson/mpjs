class C
    @foo: 10

c = new C

console.log "c.foo", C::foo

#funs = {}
#funs.f = -> @value
# console.log Object::f = -> @value
deal =
    Notional: 2000000,
    Currency: "USD"
    Product: 'CDS Index'
    'Fixing Holiday Centres': [1, 2, 3]

funs =
    f: -> console.log 'f'
    g: ->

funs2 =
    h: -> console.log 'h'

funs2.__proto__ = funs
deal.__proto__ = funs2

console.log deal.prototype


deal.f()
deal.h()

Object.prototype.foo = -> console.log "foo"

deal.foo()

# class ToCheck extends deal

# class Deal
#     value: 10

# o = new Deal()

# class Funs extends o
#      f: -> @value

# Funs.prototype = Deal::

# o1 = new Funs()
# console.log o1

# console.log o1.value
# console.log o1.f()


