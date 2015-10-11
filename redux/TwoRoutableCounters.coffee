RoutableCounter = require './RoutableCounter'
Counter = require './Counter'
Prefixer = require './Prefixer'


sides = {'left', 'right'}

prefixers =
  left: Prefixer 'L$'
  right: Prefixer 'R$'

wrapAction = (side, action) -> Object.assign {}, action, {type: prefixers[side].prefix action.type}
unwrapAction = (side, action) ->
  return null unless (type = prefixers[side].unprefix action.type)?
  return Object.assign {}, action, {type}

wrapState = (side, innerState) ->
  state = {}
  state[side] = innerState
  return state
unwrapState = (side, state) -> state[side]


actionCreators =
  left: (actionCreatorResult) ->
    if typeof actionCreatorResult is 'function' # ie, redux-thunk
      return (realDispatch, realGetState) ->
        dispatch = (a) -> realDispatch wrapAction sides.left, a
        getState = () -> unwrapState sides.left, realGetState()
        actionCreatorResult dispatch, getState
    else
      return wrapAction sides.left, actionCreatorResult

  right: (actionCreatorResult) ->
    if typeof actionCreatorResult is 'function' # ie, redux-thunk
      return (realDispatch, realGetState) ->
        dispatch = (a) -> realDispatch wrapAction sides.right, a
        getState = () -> unwrapState sides.right, realGetState()
        actionCreatorResult dispatch, getState
    else
      return wrapAction sides.right, actionCreatorResult


initialState =
  left: RoutableCounter.reducer undefined, {}
  right: RoutableCounter.reducer undefined, {}

reducer = (state = initialState, action) ->
  if (unwrappedAction = unwrapAction sides.left, action)?
    unwrappedState = unwrapState sides.left, state
    return Object.assign {}, state, {left: RoutableCounter.reducer unwrappedState, unwrappedAction}
  if (unwrappedAction = unwrapAction sides.right, action)?
    unwrappedState = unwrapState sides.right, state
    return Object.assign {}, state, {right: RoutableCounter.reducer unwrappedState, unwrappedAction}
  return state

module.exports = {sides, actionCreators, reducer, unwrapState}







# cheeky little unit tests
{ createStore, applyMiddleware } = require 'redux'
thunk = require 'redux-thunk'
createStoreWithMiddleware = applyMiddleware(thunk)(createStore)
store = createStoreWithMiddleware reducer

console.assert RoutableCounter.unwrapState(store.getState().left) is 0, 'initial state'

store.dispatch actionCreators.left RoutableCounter.actionCreators.forwardAction Counter.actionCreators.increment()
store.dispatch actionCreators.left RoutableCounter.actionCreators.forwardAction Counter.actionCreators.incrementIfOdd()

console.assert RoutableCounter.unwrapState(store.getState().left) is 2, 'thunk forwarding works!'
