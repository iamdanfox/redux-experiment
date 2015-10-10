Counter = require './Counter'


actions = { 'WRAPPED' }

wrap = ({wrappedAction, reachedByBackButton}) -> {type: actions.WRAPPED, wrappedAction, reachedByBackButton}

actionCreators =
  wrapped: (wrappedAction, reachedByBackButton = false) ->
    if typeof wrappedAction is 'function' # ie, redux-thunk
      return (realDispatch, realGetState) ->
        dispatch = (wrappedAction) -> realDispatch wrap {wrappedAction, reachedByBackButton}
        getState = () -> realGetState().wrappedState
        wrappedAction dispatch, getState
    else
      return wrap {wrappedAction, reachedByBackButton}

  handleUrl: (url) ->
    actionCreators.wrapped Counter.actionCreators.set(parseInt(url, 10))

  backToUrl: (url) ->
    actionCreators.wrapped Counter.actionCreators.set(parseInt(url, 10)), true


reducer = (state = {wrappedState: undefined, url: undefined, reachedByBackButton: false}, action) ->
  wrappedState = Counter.reducer state.wrappedState, action.wrappedAction or {}
  reachedByBackButton = if action.reachedByBackButton? then action.reachedByBackButton else false
  return { wrappedState, url: wrappedState.toString(), reachedByBackButton}


module.exports = {actions, actionCreators, reducer}

# cheeky little unit tests

{ createStore } = require 'redux'
store = createStore reducer
console.assert store.getState().wrappedState is 0, 'initial state'
console.assert store.getState().url is '0', 'initial url '

store.dispatch actionCreators.handleUrl '1'

console.assert store.getState().wrappedState is 1, 'state has changed after handleUrl'
console.assert store.getState().url is '1', 'url has changed'
console.assert store.getState().reachedByBackButton is false, 'should create history entries by default'

store.dispatch actionCreators.backToUrl '0'

console.assert store.getState().wrappedState is 0, 'state has changed after backToUrl'
console.assert store.getState().url is '0', 'url has changed'
console.assert store.getState().reachedByBackButton is true, 'should not create history entry for a back action'

store.dispatch {type:'UNKNOWN'}

console.assert store.getState().reachedByBackButton is false, 'any other action should reset reachedByBackButton'
