RoutableCounter = require './RoutableCounter'
Counter = require './Counter'
Prefixer = require './Prefixer'
ThunkForwarder = require './ThunkForwarder'

sides = {'left', 'right'}

prefixers =
  left: Prefixer 'Left-'
  right: Prefixer 'Right-'

wrapAction = (side) -> (action) -> Object.assign {}, action, {type: prefixers[side].prefix action.type}
unwrapAction = (side, action) -> if (type = prefixers[side].unprefix action.type)? then Object.assign {}, action, {type} else null
wrapState = (side, innerState) ->
  state = {}
  state[side] = innerState
  return state
unwrapState = (side) -> (state) -> state[side]

actionCreators =
  left: ThunkForwarder
    wrapAction: wrapAction sides.left
    unwrapState: unwrapState sides.left

  right: ThunkForwarder
    wrapAction: wrapAction sides.right
    unwrapState: unwrapState sides.right

initialState =
  left: RoutableCounter.reducer undefined, {}
  right: RoutableCounter.reducer undefined, {}

reducer = (state = initialState, action) ->
  if (unwrappedAction = unwrapAction sides.left, action)?
    unwrappedState = unwrapState(sides.left) state
    return Object.assign {}, state, {left: RoutableCounter.reducer unwrappedState, unwrappedAction}

  if (unwrappedAction = unwrapAction sides.right, action)?
    unwrappedState = unwrapState(sides.right) state
    return Object.assign {}, state, {right: RoutableCounter.reducer unwrappedState, unwrappedAction}

  return state

module.exports = {sides, actionCreators, reducer, unwrapState}







# cheeky little unit tests
{ createStore, applyMiddleware } = require 'redux'
thunk = require 'redux-thunk'
createStoreWithMiddleware = applyMiddleware(thunk)(createStore)
store = createStoreWithMiddleware reducer

console.assert RoutableCounter.unwrapState(store.getState().left) is 0, 'initial state'

store.dispatch actionCreators.left RoutableCounter.actionCreators.wrap Counter.actionCreators.increment()
store.dispatch actionCreators.left RoutableCounter.actionCreators.wrap Counter.actionCreators.incrementIfOdd()

console.assert RoutableCounter.unwrapState(store.getState().left) is 2, 'thunk forwarding works!'
