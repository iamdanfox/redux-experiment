{ compose } = require 'redux'
React = require 'react'
{ unwrapState, sides } = require '../redux/TwoRoutableCounters'
{ left, right } = require('../redux/TwoRoutableCounters').actionCreators
RoutableCounter = require './RoutableCounter'

TwoRoutableCounters = React.createClass
  displayName: 'TwoRoutableCounters'

  propTypes:
    reduxState: React.PropTypes.object.isRequired
    dispatch: React.PropTypes.func.isRequired

  render: () ->
    leftProps =
      reduxState: unwrapState(sides.left) @props.reduxState
      dispatch: compose @props.dispatch, left

    rightProps =
      reduxState: unwrapState(sides.right) @props.reduxState
      dispatch: compose @props.dispatch, right

    <div>
      <h1>Two Routable Counters</h1>
      <RoutableCounter {...leftProps} />
      <RoutableCounter {...rightProps} />
    </div>


module.exports = TwoRoutableCounters
