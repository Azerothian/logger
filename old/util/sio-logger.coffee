io = require "socket.io-client"
logLevels = ["info", "debug", "warn"]

class SIOLogger

  constructor: (@appName, target) ->
    if !target?
      target = "http://#{window.location.hostname}:2212"

    @msgs = []
    @socket = io.connect target
    @socket.on "connect", @onConnect
    @socket.on "disconnect", @onDisconnect

    setInterval @processQueue, 500
    @connected = false
    for level in logLevels
      @[level] = @logHook level

  logHook: (level) =>
    return () =>
      @baseLog level, arguments

  log: () =>
    @baseLog "info", arguments
    
  register: (appName) =>
    if appName?
      @socket.emit "log:register", appName

  processQueue: () =>
    if @msgs.length > 0 && @connected
      for entry in @msgs
        @sendLog entry.level, entry.msg
      @msgs = []

  sendLog: (logLevel, message) =>
    msg = "log:"
    if @appName?
      msg = "#{msg}#{@appName}:"
    @socket.emit "#{msg}#{logLevel}", message

  baseLog: (logLevel, message) =>
    processed = "''something went wrong decoding js message''"
    try
      processed = JSON.parse JSON.stringify message
    catch e
      processed = e

    @msgs.push {
      level: logLevel,
      msg: processed
    }

  onDisconnect: () =>
    @log "socket.io disconnected"
    @connected = false

  onConnect: () =>
    @log "socket.io connected"
    @register @appName
    @connected = true


module.exports = new SIOLogger()
