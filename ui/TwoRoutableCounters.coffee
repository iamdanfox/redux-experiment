React = require 'react'
RoutableCounter = require './RoutableCounter'
{ unwrapState, sides } = require '../redux/TwoRoutableCounters'
{ left, right } = require('../redux/TwoRoutableCounters').actionCreators

TwoRoutableCounters = React.createClass
  displayName: 'TwoRoutableCounters'

  propTypes:
    reduxState: React.PropTypes.object.isRequired
    dispatch: React.PropTypes.func.isRequired

  render: () ->
    leftProps =
      reduxState: unwrapState sides.left, @props.reduxState
      dispatch: (action) => @props.dispatch left action

    rightProps =
      reduxState: unwrapState sides.right, @props.reduxState
      dispatch: (action) => @props.dispatch right action

    <div>
      <h1>Two Routable Counters</h1>
      <RoutableCounter {...leftProps} />
      <RoutableCounter {...rightProps} />
    </div>


module.exports = TwoRoutableCounters
