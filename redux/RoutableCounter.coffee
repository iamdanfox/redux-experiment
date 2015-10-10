Counter = require './Counter'


actions = { 'WRAPPED' }

wrap = ({wrappedAction, shouldCreateHistory}) -> {type: actions.WRAPPED, wrappedAction, shouldCreateHistory}

actionCreators =
  wrapped: (wrappedAction, shouldCreateHistory = true) ->
    if typeof wrappedAction is 'function' # ie, redux-thunk
      return (realDispatch, realGetState) ->
        dispatch = (wrappedAction) -> realDispatch wrap {wrappedAction, shouldCreateHistory}
        getState = () -> realGetState().wrappedState
        wrappedAction dispatch, getState
    else
      return wrap {wrappedAction, shouldCreateHistory}

  handleUrl: (url) ->
    actionCreators.wrapped Counter.actionCreators.set(parseInt(url, 10))

  backToUrl: (url) ->
    actionCreators.wrapped Counter.actionCreators.set(parseInt(url, 10)), false


reducer = (state = {wrappedState: undefined, url: undefined, shouldCreateHistory: true}, action) ->
  wrappedState = Counter.reducer state.wrappedState, action.wrappedAction or {}
  shouldCreateHistory = if action.shouldCreateHistory? then action.shouldCreateHistory else true
  return { wrappedState, url: wrappedState.toString(), shouldCreateHistory}


module.exports = {actions, actionCreators, reducer}

# cheeky little unit tests

{ createStore } = require 'redux'
store = createStore reducer
console.assert store.getState().wrappedState is 0, 'initial state'
console.assert store.getState().url is '0', 'initial url '

store.dispatch actionCreators.handleUrl '1'

console.assert store.getState().wrappedState is 1, 'state has changed after handleUrl'
console.assert store.getState().url is '1', 'url has changed'
console.assert store.getState().shouldCreateHistory is true, 'should create history entries by default'

store.dispatch actionCreators.backToUrl '0'

console.assert store.getState().wrappedState is 0, 'state has changed after backToUrl'
console.assert store.getState().url is '0', 'url has changed'
console.assert store.getState().shouldCreateHistory is false, 'should not create history entry for a back action'

store.dispatch {type:'UNKNOWN'}

console.assert store.getState().shouldCreateHistory is true, 'any other action should create history by default'
