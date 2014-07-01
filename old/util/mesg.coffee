
EventEmitter = require('events').EventEmitter
minimatch = require "minimatch"

log = require "./log"


class Messenger
  constructor: () ->
    @emitter = new EventEmitter
    if not @emitter.off?
      @emitter.off = @emitter.removeListener
    @events = []
    @sources = {}
    @links = []
    @linkIndex = 0
    @eventIndex = 0
    if not @componentWillMount? and @getEvents?
      evnts = @getEvents()
      for e of evnts
        @on e, @events[e]

  registerSource: (name, filters, emitter) =>

    @sources[name] = {
      name: name
      filters: filters
      emitter: emitter
      off: []
    }

  getFilters: (name) =>
    return @source[name].filters

  setFilters: (name, filters) =>
    @source[name].filters = filters

  getSource: (name) =>
    return @sources[name]

  removeSource: (name) =>
    for o in @sources[name].off
      o()
    delete @sources[name]

  on: (evnt, func) =>
    log "mesg on: event: #{evnt}"

    @eventIndex++
    @emitter.on evnt, func

    hookFunc = () =>
      log "mesg: on: event: #{evnt}, source: #{sourceName} fired"
      func.apply undefined, arguments

    offSrc = []
    for sourceName of @sources
      if @validateFilters evnt, @sources[sourceName].filters.on
        log "mesg: on: event: #{evnt}, source: #{sourceName} set"
        @sources[sourceName].emitter.on evnt, hookFunc
        offFunc = () =>
          @sources[sourceName].emitter.off evnt, hookFunc
        offSrc.push offFunc
        @sources[sourceName].off.push offFunc

    @events.push {
      id: @eventIndex
      name: evnt
      off: () =>
        @emitter.off evnt, hookFunc
        for s in offSrc
          s()
    }

    return @eventIndex


  off: (id) =>
    log "mesg off: #{id}"
    for i in @events
      if i.id is id
        log "mesg off: #{i.name}"
        i.off()
        #todo: delete from array

  emit: (evnt) =>
    log "mesg emit: #{arguments[0]}", arguments

    for sourceName of @sources
      if @validateFilters evnt, @sources[sourceName].filters.emit
        log "mesg source emit: #{evnt} - #{sourceName}"
        @sources[sourceName].emitter.emit.apply @sources[sourceName].emitter, arguments

    @emitter.emit.apply @emitter, arguments

  validateFilters: (text, filters) =>
    arrs = filters.filter (f) ->
      result = minimatch text, f
      log "validateFilters #{text} #{f} #{result}"
      return result
    total = arrs.length
    log "validateFilters #{text} #{total}"
    return total == filters.length

module.exports = Messenger
