io = require "socket.io-client"
defaults = {
  host: "127.0.0.1"
  port: 2213
  protocol: "http://"
}

if window?
  defaults.host = window.location.hostname

class Logger
  @scope: "singleton"
  constructor: () ->
    @messages = []

  connect: ( hostname = defaults.host, port = defaults.port, protocol = defaults.protocol) =>
    @connected = false
    target = "#{protocol}#{hostname}:#{port}"
    @socket = io.connect target
    @socket.on "connect", @onConnect
    @socket.on "disconnect", @onDisconnect

    setInterval @sendMessage, 5000

  sendMessage: () =>
    if @messages.length > 0 && @connected
      for m in @messages
        out = ""
        try
          out = JSON.parse JSON.stringify(m.message)
        catch e
          out = e
        @socket.emit m.timestamp, m.event, m.application, m.component, out
      @messages = []

  log: (application, component, message) =>
    @messages.push {
      event: "/log"
      timestamp: @formatDate()
      application: application
      component: component
      message: message
    }

  onDisconnect: () =>
    @log "socket.io disconnected"
    @connected = false

  onConnect: () =>
    @log "socket.io connected"
    @connected = true

  fill0: (s, k) ->
    (if s.length is k then s else "0" + @fill0(s, k - 1))
  formatDate: ->
    now = new Date()
    year = now.getUTCFullYear()
    month = @fill0((now.getUTCMonth() + 1) + "", 2)
    day = @fill0((now.getUTCDate()) + "", 2)
    return year + "." + month + "." + day



if window?
  if !window.logger?
    window.logger = new Logger
  module.exports = window.logger
  return
else
  module.exports = new Logger
