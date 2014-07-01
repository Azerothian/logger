logger = require "./sio-logger"

$(document).ready () ->
  logger.connect()

  f = () ->
    logger.log "website", "sockets", {
      details: "log details"
      ex: "error"
      t: "loltrace"
    }

  e = () ->
    $.post "/log", {
      application: "website"
      component: "express"
      message:
        details: "log details"
        ex: "error"
        t: "loltrace"
      }

  setInterval f, 10000
  setInterval e, 5000
