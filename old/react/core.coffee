React = require "react"
logBrowser = require "./logBrowser/"
dock = require "./dock"

module.exports = React.createClass {
  render: () ->
    dock {
      title: "Illisian"
      components: [
        logBrowser()
      ]
    }
}
