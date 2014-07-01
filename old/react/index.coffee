
ReactManager = require "../util/reactmanager"
reactManager = new ReactManager()

Logic = require "./logic/"

module.exports = reactManager.getReact() #hack for server renderering
