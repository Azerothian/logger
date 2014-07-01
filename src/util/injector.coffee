inject = require "honk-di"
injector = new inject.Injector()

class Injector
  constructor: ->
    if @getLibs?
      libs = @getLibs()
      for l of libs
        @[l] = injector.getInstance libs[l]


module.exports = Injector
