
React = require "react"
mesg = require "./mesg-static"

if window?
  window.React = React
React.initializeTouchEvents true


{div} = React.DOM

ReactManager

class ReactManager

  constructor: () ->

    mesg.on "react:component:add", @onReactAddComponent
    mesg.on "react:component:remove", @onReactRemoveComponent
    @components = {}

    if document?
      $(document).ready @onDocumentReady

  onReactAddComponent: (name, component) =>
    if @components[name]?
      #todo: log "warning component already set", trigger remove?
      @onReactRemoveComponent name

    @components[name] = component
    @update()
  onReactRemoveComponent: (name) =>
    if @components[name]?
      delete @components[name]
    @update()

  @getBaseReact: (manager) =>
    return React.createClass {
      render: ->
        args = [{ className: "row" }]
        for component of manager.components
          args.push manager.components[component]()

        return div.apply undefined, args
    }
  getReact: () =>
    return ReactManager.getBaseReact @
  onDocumentReady: () =>
    if $("#react-root").length is 0
      $("body").append $("<div id='react-root'></div>")
    @reactMain = React.renderComponent ReactManager.getBaseReact(@)(), document.getElementById('react-root')
  update: () =>
    if @reactMain?
      @reactMain.forceUpdate()

module.exports = ReactManager
