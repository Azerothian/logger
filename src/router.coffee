mesg = require "./util/mesg"
log = require "./util/log"
winston = require "winston"
util = require "util"


# Applications - winston instance
# Sections - winston.container
# LogEntries

class Router
  constructor: ->
    @apps =  []
    @createApp "global"

  createApp: (appName) =>
    @apps[appName] = new Application appName
    return @apps[appName]



  socketio: (err, socket, session) =>
    socket.on "log:create", (name) =>
      if !@apps[name]?
        @apps[name] = @createApp name
      @apps[name].socketio socket

    socket.on "log", @apps["global"].logSocketHook "info", socket

    for logLevel of winston.config.syslog.levels
      socket.on "log:#{logLevel}", @apps["global"].logSocketHook logLevel, socket


defaultAppSetting = {
  transports: [
    new winston.transports.Console {
      handleExceptions: true,
      json: true
    }
  ],
  exitOnError: false
}

class Application
  constructor: (@name, @options = defaultAppSetting) ->
    @winston = new winston.Logger @options

    for logLevel of winston.config.syslog.levels
      @[logLevel] = logHook logLevel

  logHook: (logLevel) =>
    return () =>
      @log logLevel, arguments

  log: (logLevel, source, message) =>
    @winston[logLevel].apply logger, {src: source, msg: message}

  socketio: (socket) =>
    socket.on "log:#{@name}", @logSocketHook "info", socket

    for i of winston.config.syslog.levels
      socket.on "log:#{name}:#{i}", @logSocketHook(i, socket)

#    socket.on "disconnect", () =>
      #@winston.log "info", "logger", "'#{socket.conn.id}' socket disconnected"

  logSocketHook: (logLevel, socket) =>
    return () =>
      source = {
        ip: ""
      }
      return @log logLevel, source, arguments

args = (a) ->
  return Array.prototype.slice.call a, 0


module.exports = Router

# category, [ message ]
###
class Router
  constructor: () ->
    @winston = new WinstonManager()



  express: (expressApp) =>
    expressApp.post '/logger/log', @logExpressHook("info")

    for i of winston.config.syslog.levels
      expressApp.post "/logger/#{i}", @logExpressHook(i)


  socketio: (err, socket, session) =>
    socket.on "logger:log", @logSocketHook("info", socket)

    for i of winston.config.syslog.levels
      socket.on "logger:#{i}", @logSocketHook(i, socket)

    @winston.log "info", "logger", "'#{socket.conn.id}' socket connected"
    socket.on "disconnect", () =>
      @winston.log "info", "logger", "'#{socket.conn.id}' socket disconnected"


  logSocketHook: (logType, socket) =>
    return () =>
      params = [logType, "socketio [#{socket.conn.id}]"].concat args(arguments)
      @winston.log.apply @winston, params

  logExpressHook: (logType) =>
    return (req, res, next) =>
      if req.body?
        params = [logType, "express [#{req._remoteAddress}]"]
        if Array.isArray req.body
          params.push i for i in req.body
        else
          params.push req.body
        @winston.log.apply @winston, params
        res.send "true"
      else
        res.send "false"
      #next()
      #params = [logType, "socketio [#{socket.conn.id}]"].concat args(arguments)
      #@winston.log.apply @winston, params

class WinstonManager
  constructor: () ->
    @container = new winston.Container()


  getEvents: () =>
    return {
      "logger:log": @log
      "logger:source:create": @createContainer
    }

  createContainer: (source, level = 'info', colorize = 'true') =>
    log "createContainer - start  #{source}"
    @container.add source, {
      console:
        level: level,
        colorize: colorize
      transports:[
        #new winston.transports.Console { level: 'info'}
      ]
    }

  getContainer: (source) =>
    if !@container.has source
      @createContainer source
    return @container.get source

  log: (logType, source) =>
    #arguments by default does not have the splice command
    params = args(arguments).splice 1, arguments.length - 1

    container = @getContainer source

    if container[logType]?
      container[logType].apply container, params
    else
      console.log "broken log type '#{logType}'"



module.exports = Router


    @static = []
    @msg = new mesg()
    for l of logic
      v = new logic[l]
      v.emit = () =>
        @msg.emit.apply @msg, arguments
      v.on = () =>
        @msg.on.apply @msg, arguments
      if v.getEvents?
        events = v.getEvents()
        for evt of events
          log "onevnt: #{evt}"
          v.on evt, events[evt]

  express: (req, res, next) =>
    next()

  socketio: (err, socket, session) =>
    log "Router - socketio", err
    @msg.registerSource socket, {
      on: ["*"]
      emit: ["*"]
    }, socket

    socket.on "disconnect", () =>
      log "removeSource"
      @msg.removeSource socket





module.exports = Router
###
