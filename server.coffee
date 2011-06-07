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
    @url = 'http://localhost:3000'
    @logging = false
    @images = {}

  start: ->
    @._log "=> Receiver started on port #{@port} with a limit of #{@limit}"
    @_server.listen @port

  _upload: (req, res) ->
    req.addListener 'data', (data) =>
      filename = new Date().getTime()
      @images[filename] = data
      @._delete_oldest_image() if _.size(@images) > @limit
      res.end("#{@url}/#{filename}")

  _display: (req, res) ->
    filename = req.url.substr(1)
    if img = @images[filename]
      res.writeHead(200, {'Content-Type': 'image/png'});
      res.end(img)
    else 
      res.writeHead(404);
      res.end()

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
  @port = 3000
  @limit = 30
