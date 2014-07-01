log = require "./log"
if window?
  if window.mesg?
    module.exports = window.mesg
    return
mm = require "./mesg"
log "Creating static mesg"
mesg = new mm()
if window?
  window.mesg = mesg
  module.exports = window.mesg
else
  module.exports = mesg
