React = require 'react'
{ unwrapState, sides } = require '../redux/TwoRoutableCounters'
{ left, right } = require('../redux/TwoRoutableCounters').actionCreators

Counter = require './Counter'
ReduxNest = require './ReduxNest'
RoutableCounter = require '../redux/RoutableCounter'
RoutableCounterComponent = ReduxNest Counter, RoutableCounter.unwrapState, RoutableCounter.actionCreators.forwardAction


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
      <RoutableCounterComponent {...leftProps} />
      <RoutableCounterComponent {...rightProps} />
    </div>


module.exports = TwoRoutableCounters
