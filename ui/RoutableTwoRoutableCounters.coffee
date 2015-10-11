reduxNestComponent = require '../nest/ReduxNestComponent'
{ unwrapState, actionCreators } = require '../redux/RoutableTwoRoutableCounters'
routableTwoRoutableCounters = reduxNestComponent
  inner: require './TwoRoutableCounters'
  unwrapState: unwrapState
  wrap: actionCreators.wrap

module.exports = routableTwoRoutableCounters
