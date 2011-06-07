http = require 'http'
_ = require 'underscore'

class Receiver
  constructor: ->
    @_server = http.createServer (req, res) =>
      if req.method is 'POST'
        @._upload req, res
      else
        @._display req, res

    @port = 3000
    @limit = 2
    @logging = false
    @images = {}

  start: ->
    @._log "=> Receiver started on port #{@port} with a limit of #{@limit}"
    @_server.listen @port

  _upload: (req, res) ->
    req.setEncoding('binary')
    req.content = ''

    req.addListener 'data', (data) =>
      req.content += data

    req.addListener 'end', (data) =>
      filename = new Date().getTime()
      buf = new Buffer(req.content.length)
      buf.write(req.content, 0, 'binary')
      @images[filename] = buf
      @._delete_oldest_image() if _.size(@images) > @limit
      res.end("http://#{req.headers.host}/#{filename}")

  _display: (req, res) ->
    filename = req.url.substr(1)
    if img = @images[filename]
      res.writeHead(200, {'Content-Type': 'image/png'});
      res.end(img)
    else 
      res.writeHead(200, {'Content-Type': 'text/html'});
      res.end('No Image')

  _delete_oldest_image: ->
      @._log "=> Removing Oldest Image"
      delete @images[_.min(_.keys(@images))] 

  _log: (msg) ->
    console.log "=> #{msg}" if @logging

  @config: (configs) ->
    recv = new Receiver()
    configs.call(recv)
    recv.start()

Receiver.config ->
  @port = 80
  @limit = 30
