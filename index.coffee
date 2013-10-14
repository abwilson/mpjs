cluster = require "cluster"
http = require "http"
url = require "url"
rules = require "./rules"
util = require "util" 

log = console.log
_log = ->

if false and cluster.isMaster
    for i in [0..2] by 1
        cluster.fork()
    cluster.on 'exit', (worker, code, signal) ->
        console.log 'worker ' + worker.process.pid + ' died'
else
    svr = http.createServer (req, res) ->
        log "Request", req.method, req.headers
        body = '';
        req.setEncoding('utf8');

        req.on 'data', (chunk) ->
            _log chunk
            body += chunk

        req.on 'end', ->
            req.url = url.parse req.url, true
            _log req.url, req.url.query
            try
                data = JSON.parse body
            catch ex
                res.statusCode = 400
                log ex.message
                return res.end 'error: ' + ex.message

            res.writeHead 200,
                'Content-Type': 'text/plain'
            result = rules[req.url.query.rules].check data
            _log result
            res.write util.inspect result
            res.end()
            log "Sucess"

    svr.listen 8080

    log "Started"
