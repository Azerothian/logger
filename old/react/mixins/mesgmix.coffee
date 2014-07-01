mesg = require "../mesg-static"

log  = require "../log"


module.exports = {
  on: ->
    return mesg.on.apply undefined, arguments
  emit: ->
    return mesg.emit.apply undefined, arguments
  off: ->
    return mesg.off.apply undefined, arguments

  componentWillMount: ->
    @eventRefs = []
    if @getEvents?
      @eventRefs = @getEvents().map (ev) =>
        {
          name: ev.name
          id: mesg.on ev.name, ev.func
        }

  componentWillUnmount: ->
    for ev in @eventRefs
      log "[mesgmixin] #{ev.name}, #{ev.id}"
      mesg.off ev.id

}
