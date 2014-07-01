proxyLog = () ->

if console?
  if Function?
    if Function.prototype?
      if Function.prototype.bind?
        proxyLog = Function.prototype.bind.call(console.log, console);
      else
        proxyLog = () ->
          Function.prototype.apply.call(console.log, console, arguments)
  else if console.log?
    if console.log.apply?
      proxyLog = () ->
        console.log.apply console, arguments



#module.exports = proxyLog


io = require "socket.io-client"

class Logger

  constructor: (target) ->
    if !target?
      target = "http://#{window.location.hostname}:2212"

    @messages = []
    @socket = io.connect target
    @socket.on "connect", @onConnect

    @socket.on "disconnect", @onDisconnect

    setInterval @sendMessage, 500
    @connected = false

  sendMessage: () =>
    if @messages.length > 0 && @connected
      for message in @messages
        out = ""
        try
          out = JSON.stringify message
        catch e
          out = e
        @socket.emit.apply @socket, ["logger:log","website","info", out]
      @messages = []

  onDisconnect: () =>
    @log "socket.io disconnected"
    @connected = false

  onConnect: () =>
    @log "socket.io connected"
    @connected = true

  log: =>
    proxyLog.apply undefined, arguments
    @messages.push arguments

module.exports = new Logger().log
