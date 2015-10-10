Counter = require './Counter'


actions = { 'WRAPPED' }

wrap = ({action, createHistoryEntry}) -> {type: actions.WRAPPED, wrappedAction: action, createHistoryEntry}

actionCreators =
  wrapped: (action, createHistoryEntry = true) ->
    if typeof wrappedAction is 'function' # ie, redux-thunk
      return (realDispatch, realGetState) ->
        dispatch = (wrappedAction) -> realDispatch wrap {action, createHistoryEntry}
        getState = () -> realGetState().wrappedState
        wrappedAction dispatch, getState
    else
      return wrap {action, createHistoryEntry}

  handleUrl: (path) ->
    actionCreators.wrapped Counter.actionCreators.set(parseInt(path, 10))

  backToUrl: (path) ->
    actionCreators.wrapped Counter.actionCreators.set(parseInt(path, 10)), false


reducer = (state = {wrappedState: undefined, url: undefined, createHistoryEntry: true}, action) ->
  wrappedState = Counter.reducer state.wrappedState, action.wrappedAction or {}
  oldUrl = state.url
  newUrl = wrappedState.toString()

  createHistoryEntry = (newUrl isnt oldUrl) and (if action.createHistoryEntry? then action.createHistoryEntry else true)

  return { wrappedState, url: newUrl, createHistoryEntry}


module.exports = {actions, actionCreators, reducer}

# cheeky little unit tests

{ createStore } = require 'redux'
store = createStore reducer
console.assert store.getState().wrappedState is 0, 'initial state'
console.assert store.getState().url is '0', 'initial url '

store.dispatch actionCreators.handleUrl '1'

console.assert store.getState().wrappedState is 1, 'state has changed after handleUrl'
console.assert store.getState().url is '1', 'url has changed'
console.assert store.getState().createHistoryEntry is true, 'should create history entries by default'

store.dispatch actionCreators.backToUrl '0'

console.assert store.getState().wrappedState is 0, 'state has changed after backToUrl'
console.assert store.getState().url is '0', 'url has changed'
console.assert store.getState().createHistoryEntry is false, 'should not create history entry for a back action'

store.dispatch {type:'UNKNOWN'}

console.assert store.getState().createHistoryEntry is false, 'unchanged url shouldnt create history'
