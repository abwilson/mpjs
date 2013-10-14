restify = require "restify"
rules = require "./rules"

log = console.log
_log = ->


server = restify.createServer name: "clearing-rules"

server.use restify.fullResponse()
server.use restify.bodyParser()
server.use restify.queryParser()

server.post "/check", (req, res) ->
    _log req
    result = rules[req.query.rules].check req.params
    res.send 201, result

server.listen 3000, () ->
    console.log '%s listening at %s', server.name, server.url
