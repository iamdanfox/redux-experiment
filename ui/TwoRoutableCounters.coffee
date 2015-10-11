{ compose } = require 'redux'
React = require 'react'
{ unwrapState, sides } = require '../redux/TwoRoutableCounters'
{ left, right } = require('../redux/TwoRoutableCounters').actionCreators

Counter = require './Counter'
reduxNestComponent = require '../nest/ReduxNestComponent'
RoutableCounter = require '../redux/RoutableCounter'
RoutableCounterComponent = reduxNestComponent
  inner: Counter
  unwrapState: RoutableCounter.unwrapState
  wrap: RoutableCounter.actionCreators.wrap


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
      <RoutableCounterComponent {...leftProps} />
      <RoutableCounterComponent {...rightProps} />
    </div>


module.exports = TwoRoutableCounters
