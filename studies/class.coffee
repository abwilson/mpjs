
class Base
    constructor: (@x=10) -> 1 + 3
    @foo: 10    
    bar: 9
    local = 7
    f: local

b = new Base

b2 = new Base

b2.bar = 11
b.bar = 5

b.prototype =
    x: 8

console.log Base.foo, b.bar, b.prototype, b.x

class Derived extends Base
