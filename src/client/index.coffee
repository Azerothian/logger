logger = require "./sio-logger"

$(document).ready () ->
  logger.connect()

  f = () ->
    l = Math.floor(Math.random() * 20) + 1
    for i in [0...l]
      logger.log "website", "sockets", {
        details: "log details"
        ex: "error"
        t: "loltrace"
      }

  e = () ->
    l = Math.floor(Math.random() * 20) + 1
    for i in [0...l]
      $.post "/log", {
        timestamp: new Date()
        application: "website"
        component: "express"
        message:
          details: "log details"
          ex: "error"
          t: "loltrace"
      }

  setInterval f, 10000
  setInterval e, 5000
