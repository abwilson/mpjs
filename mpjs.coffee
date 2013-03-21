parser   = require './grammar'
nodes    = require './nodes'
nodes.parser = parser
{Buffer} = require './emitter'

fs       = require 'fs'
path     = require 'path'
optimist = require 'optimist'
util     = require 'util'

exports.result = false

do ->
    log = console.log

    argv = optimist.demand('o').argv

    nodes.filename = argv._

    source = fs.readFileSync(path.resolve(argv._[0]), "utf8");

# parser.yy = { result: false }

    try
        tree = parser.parse(source)
    catch ex
        console.error ex
        throw ex

    # log 'yy', exports.result

    buffer = new Buffer()
    # log util.inspect exports.result, false, 10
    exports.result.emit(buffer)

    fs.writeFile argv.o, buffer.buffer(), (err) ->
        if err
            console.error err.message
    #    else
    #        log "Jobs a good 'un"

