Promise = require "bluebird"
Checkit = require "checkit"

moment = require "moment"

elasticsearch = require "elasticsearch"

util = require "util"

config = require "./config"

injector = require "./util/injector"



class Logger extends injector
  @scope: "singleton"# DONT store local objects

  getLibs: () ->
    {
      "config": config
    }


  constructor: () ->
    super
    @checkit = new Checkit {
      timestamp: 'required'
      application: 'required'
      component: 'required'
    }
    @elastic = new elasticsearch.Client @config.elasticsearch
    @elastic.indices.delete({
      index: @getLogIndex()
    }).then () ->
      console.log "delete complete"
    , () ->
      console.log "delete rejected"
    #debugger

  getLogIndex: () ->
    return "logstash-#{moment().format("YYYY.MM.DD")}"

  getEvents: () =>
    {
      "log": @log
      "log/debug": @log
    }
  log: (source, message) =>
    #args = arguments
    return new Promise (resolve, reject) =>
      if !moment(message.timestamp).isValid()
        #console.log "invalid date time"
        message.timestamp = new Date()
      else
        #console.log "valid date time using moment to parse"
        message.timestamp = moment(message.timestamp).toDate()
      @checkit.run(message).then () =>

        m = {
          index: @getLogIndex()
          type: message.application
          body:
            "@version": 1
            "@timestamp": message.timestamp
            "@sys_timestamp": new Date()
            source: message.component

        }
        for msg of message
          m[msg] = message[msg]

        @elastic.index(m).then () ->
          console.log "elastic index resolve", arguments
      , (err) ->
        #"invalid"
      #
      resolve true

module.exports = Logger
