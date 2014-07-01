log = () ->

if console?
  if Function?
    if Function.prototype?
      if Function.prototype.bind?
        log = Function.prototype.bind.call(console.log, console)
      else
        log = () ->
          Function.prototype.apply.call(console.log, console, arguments)
  else if console.log?
    if console.log.apply?
      log = () ->
        console.log.apply console, arguments

class Log
  @scope: "singleton"
  constructor: () ->

  log: log

  info: log

  debug: log

module.exports = Log
