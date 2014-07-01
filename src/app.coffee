injector = require "./util/injector"

config = require "./config"
server = require "./server"

logger = require "./logger"


class App extends injector


  constructor: () ->
    super

  getLibs: () =>
    {
      #"config": config
      "server": server
      "logger": logger
    }

  init: () =>
    @server.registerModule @logger
    return @server.init()

module.exports = new App().init()
