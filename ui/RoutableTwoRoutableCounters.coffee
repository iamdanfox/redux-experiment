reduxNestComponent = require '../nest/ReduxNestComponent'
{ unwrapState, actionCreators } = require '../redux/RoutableTwoRoutableCounters'
routableTwoRoutableCounters = reduxNestComponent
  inner: require './TwoRoutableCounters'
  unwrapState: unwrapState
  innerAction: actionCreators.innerAction

module.exports = routableTwoRoutableCounters
