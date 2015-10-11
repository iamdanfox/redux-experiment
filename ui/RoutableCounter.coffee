reduxNestComponent = require '../nest/ReduxNestComponent'
{ unwrapState, actionCreators } = require '../redux/RoutableCounter'
RoutableCounter = reduxNestComponent
  inner: require './Counter'
  unwrapState: unwrapState
  innerAction: actionCreators.innerAction

module.exports = RoutableCounter
