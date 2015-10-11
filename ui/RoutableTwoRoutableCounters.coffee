React = require 'react'
Inner = require './TwoRoutableCounters'
{ unwrapState } = require '../redux/RoutableTwoRoutableCounters'
{ forwardAction } = require('../redux/RoutableTwoRoutableCounters').actionCreators

RoutableTwoRoutableCounters = React.createClass
  displayName: 'RoutableTwoRoutableCounters'

  propTypes:
    reduxState: React.PropTypes.object.isRequired
    dispatch: React.PropTypes.func.isRequired

  render: () ->
    props =
      reduxState: unwrapState @props.reduxState
      dispatch: (action) => @props.dispatch forwardAction action

    <Inner {...props} />


module.exports = RoutableTwoRoutableCounters
