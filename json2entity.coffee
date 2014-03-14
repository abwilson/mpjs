fs       = require 'fs'
path     = require 'path'
optimist = require 'optimist'

argv = optimist.argv

source = fs.readFileSync(path.resolve(argv._[0]), "utf8")

o = JSON.parse source

clone = (obj) ->
    if not obj? or typeof obj isnt 'object'
        return obj

    if obj instanceof Date
        return new Date(obj.getTime()) 

    if obj instanceof RegExp
        flags = ''
        flags += 'g' if obj.global?
        flags += 'i' if obj.ignoreCase?
        flags += 'm' if obj.multiline?
        flags += 'y' if obj.sticky?
        return new RegExp(obj.source, flags) 

    newInstance = new obj.constructor()

    for key of obj
        newInstance[key] = clone obj[key]

    return newInstance

ent = { x: 10 }

log = console.log

log ent
log ent.prototype

ent2 = {}
ent2.__proto__ = ent

log ent2.x

for k, v of ent2
    log k, v

count = 0

for id, version of o
    log id
    log version.bilateral['Version Originator']
    log version.bilateral['Contract State']
    for k of version.bilateral
        count++

log count

count = 0

for id, version of o
    ent = {}
    ent.__proto__ = prev
    for k, v of version.bilateral
        if k not of ent or ent[k] != v
            ent[k] = v
            count++
    prev = ent

log count

showDelta = (o) ->
    for k, v of o
        if not o.hasOwnProperty k
            log k, v

showAllDelta = (o) ->
    while o?
        showDelta o
        o = o.__proto__
        
    
#showDelta ent    

# console.log ent
# console.log o
