Promise = require "bluebird"
Checkit = require "checkit"
#elasticsearch = require "elasticsearch";





class Logger
  @scope: "singleton"# DONT store local objects
  constructor: () ->
    @checkit = new Checkit {
      application: 'required'
      component: 'require'
    }

  getEvents: () =>
    {
      "log": @log
      "log/debug": @log
    }
  log: (source, message) =>
    args = arguments
    return new Promise (resolve, reject) =>
      @checkit.run(message).then () =>
        console.log "Application: #{message.application} Component: #{message.component}", message.message
        #"valid"

      , (err) =>
        #"invalid"
      #
      resolve true


module.exports = Logger
