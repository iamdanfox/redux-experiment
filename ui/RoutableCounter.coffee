reduxNestComponent = require '../nest/ReduxNestComponent'
{ unwrapState, actionCreators } = require '../redux/RoutableCounter'
RoutableCounter = reduxNestComponent
  inner: require './Counter'
  unwrapState: unwrapState
  wrap: actionCreators.wrap

module.exports = RoutableCounter
