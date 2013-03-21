console.log 'null == undefined', null == undefined


data =
    foo:
        bar: 10

console.log data['foo']?['bar']
console.log data['boo']?['far']
console.log data['boo']['far']
