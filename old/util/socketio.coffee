


EventEmitter = require('events').EventEmitter
io = require "socket.io-client"

class SocketIO
  constructor: (@onReady) ->
    @socket = io.connect "http://localhost:2212/"
    @socket.on "connect", @onConnect

  onConnect: () =>
    if @onReady?
      @onReady()

  on: (name, func) =>
    return @socket.on name, func

  off: (name, func) =>
    return @socket.off name, func

  emit: =>
    @socket.emit.apply @socket, arguments




class SocketIO
  constructor: () ->
    @sockets = {}

  connect: (target, connect = [], disconnect = []) =>
    if !@sockets[target]?
      @sockets[target] = {
        target: target
        socket: io.connect target
        onConnect: [connect]
        onDisconnect: [disconnect]
        connected: false
      }
      @sockets[target].socket.on "connect", () =>
        @sockets[target].connected = true
        @fireEvents target, connect

        @sockets[target].socket.on "disconnect", () =>
          @sockets[target].connected = false
          for evnts in @sockets[target].onDisconnect
            @fireEvents target, evnts

    else if @sockets[target].connected
      @sockets[target].onConnect.push connect
      @sockets[target].onDisconnect.push disconnect
      @fireEvents target, connect
      

  fireEvents: (target, events) =>
    for evt in events
      evt @sockets[target].socket


  onConnect: (socket, target) =>


  onConnectHook


module.exports = SocketIO
