io = require "socket.io-client"
defaults = {
  host: "127.0.0.1"
  port: 2212
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

    setInterval @sendMessage, 1000

  sendMessage: () =>
    if @messages.length > 0 && @connected
      for m in @messages
        out = ""
        try
          out = JSON.stringify m.message
        catch e
          out = e
        @socket.emit m.event, m.application, m.component, out
      @messages = []

  log: (application, component, message) =>
    @messages.push {
      event: "/log"
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


if window?
  if !window.logger?
    window.logger = new Logger
  module.exports = window.logger
  return
else
  module.exports = new Logger
