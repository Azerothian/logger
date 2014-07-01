
mesg = require "../../util/mesg-static"
socketio = require "../../util/socketio"


if localStorage?
  localStorage.debug=''#'*'


class Router
  constructor: () ->
    @sio = new socketio

    mesg.registerSource "socketio", {
      on: ["*"]
      emit: ["*"]
    }, @sio

    mesg.emit "react:component:add", "core", require "../core"

#debugger


module.exports = new Router()
