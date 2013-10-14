plt = require("restify")

respond = (req, res, next) ->
#    console.log req
    res.send "some people have no idea about technology " + req.params.name
#    res.send String(req)

server = plt.createServer()
server.get "/hello/:name", respond
server.head "/hello/:name", respond

server.listen 8081,  () -> 
    console.log "%s listening at %s", server.name, server.url
