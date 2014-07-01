
React = require "react"
{div, h1, h2, a } = React.DOM
{Button} = require "react-bootstrap"

mesgmix = require "../../util/mixins/mesgmix"


module.exports = React.createClass {
  mixins: [mesgmix]
  statics: {
    getName: () ->
      return "logbrowser"
    getDisplayName: () ->
      return "Log Browser"
  }
  getDefaultProps: ->
    return {
      "name": @type.getDisplayName()
    }
  getInitialState: () ->
    {
    }

  getEvents: () ->
    return []


  render: ->
    div {},
      h1 {}, @props.name
      div {className: "col-xs-12"}, "LogBrowser Content"
      Button { onClick: @fireEvent }, "YEY"

  fireEvent: () ->
    @emit "logger:debug", "HI!!!!"
}
