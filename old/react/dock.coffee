
React = require "react"
{div, li, a} = React.DOM
{Navbar, Nav, NavItem,MenuItem, DropdownButton} = require "react-bootstrap"

module.exports = React.createClass {
  getDefaultProps: ->
    return {
      "title": "Title"
      components: []
    }
  getInitialState: ->
    return {
      "active": undefined
    }
  componentDidMount: () ->

  componentWillUnmount: () ->

  render: ->
    div {},
      Navbar {title: @props.title }, Nav {},
        DropdownButton { title: "System" },
          @props.components.map (component) =>
            MenuItem {
              key: component.type.getName()
              onClick: @onNavComponentClick component
              className: "active" if @isActive component
            }, component.type.getDisplayName()
      @renderComponent()

  isActive: (component) ->
    return component.type.getName() is @state.active

  renderComponent: () ->
    if @state.active?
      for c in @props.components
        if @state.active == c.type.getName()
          return c
    return div {}, "Nothing Active"


  onNavComponentClick: (component) ->
    return () =>
      @setState { active: component.type.getName() }



}
