React = require 'react'
Counter = require './Counter'
{ unwrapState } = require '../redux/RoutableCounter'
{ forwardAction } = require('../redux/RoutableCounter').actionCreators

RoutableCounter = React.createClass
  displayName: 'RoutableCounter'

  propTypes:
    reduxState: React.PropTypes.object.isRequired
    dispatch: React.PropTypes.func.isRequired

  render: () ->
    props =
      reduxState: unwrapState @props.reduxState
      dispatch: (action) => @props.dispatch forwardAction action

    <Counter {...props} />


module.exports = RoutableCounter
