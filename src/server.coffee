
## - Internal
injector = require "./util/injector"
log = require "./util/log"
config = require "./config"

## - External

morgan = require "morgan"
express = require "express"
http = require "http"
socketio = require "socket.io"
bodyParser = require "body-parser"

#Promise = require "bluebird"
#EventEmitter = require("events").EventEmitter

argsToArray = (args) ->
  a = []
  a.push i for i of args
  return a



class Server extends injector
  @scope: "singleton"
  constructor: () ->
    super
    @expressApp = express()
    @httpServer = http.createServer @expressApp
    @io = socketio @httpServer
    @modules = []
    @sockets = []

  getLibs: () =>
    {
      "config": config
      "log": log
    }

  registerModule: (cls) =>
    @modules.push cls


  init: () =>
    staticPath = @config.getPath @config.express.staticPath

    @expressApp.use morgan 'dev'
    @expressApp.use bodyParser.json()
    @expressApp.use bodyParser.urlencoded { extended: true }

    for m in @modules
      events = m.getEvents()
      for e of events
        @expressApp.post "/#{e}", @expressHook(e, events[e])

    @io = socketio @httpServer
    @io.on "connection", @onSocketConnection

    @expressApp.use express.static staticPath

    @httpServer.listen @config.express.port

    @log.info "listening on #{@config.express.port}"

    return @expressApp

  expressHook: (eventName, func) ->
    return (req, res) ->
      return func({ req: req, res: res }, req.body).then () ->
        res.json arguments
      , () ->
        log.info "express hook rejected - closing connection"
        res.send "false"

  onSocketConnection: (socket) =>
    @log.info "onSocketConnection - start"
    @sockets.push socket
    for m in @modules
      events = m.getEvents()
      for e of events
        socket.on "/#{e}", @socketHook(socket, e, events[e])

  socketHook: (socket, eventName, func) =>
    return (application, component, message) =>
      return func({ id: "socket", socket: socket }, { application: application, component: component, message: message }).then () =>
        socket.emit eventName, arguments
      , () =>
        @log.info "socket hook rejected - will not emit a response"

module.exports = Server
