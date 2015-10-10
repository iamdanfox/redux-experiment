Counter = require './Counter'


actions = { 'WRAPPED' }

wrapAction = ({action, createHistoryEntry}) -> {type: actions.WRAPPED, wrappedAction: action, createHistoryEntry}
unwrapAction = (action) -> action.wrappedAction

wrapState = (state) -> {wrappedState: state}
unwrapState = (state) -> state.wrappedState

actionCreators =
  wrapped: (action, createHistoryEntry = true) ->
    if typeof action is 'function' # ie, redux-thunk
      return (realDispatch, realGetState) ->
        dispatch = (a) -> realDispatch wrapAction {action: a, createHistoryEntry}
        getState = () -> unwrapState realGetState()
        action dispatch, getState
    else
      return wrapAction {action, createHistoryEntry}

  handlePath: (path, createHistoryEntry = true) ->
    if path is '' # initial load
      initial = Counter.reducer undefined, {}
      return actionCreators.wrapped Counter.actionCreators.set(initial), createHistoryEntry

    number = parseInt path, 10
    return actionCreators.wrapped Counter.actionCreators.set(number), createHistoryEntry

  backToPath: (path) ->
    actionCreators.handlePath path, false


initialState = Object.assign wrapState(Counter.reducer undefined, {}), {url: undefined, createHistoryEntry: true}

reducer = (state = initialState, action) ->
  coreState = Counter.reducer unwrapState(state), unwrapAction(action) or {}
  oldUrl = state.url
  url = coreState.toString()
  createHistoryEntry = (url isnt oldUrl) and (if action.createHistoryEntry? then action.createHistoryEntry else true)
  return Object.assign wrapState(coreState), {url, createHistoryEntry}


module.exports = {actions, actionCreators, reducer, unwrapState}

# cheeky little unit tests

{ createStore } = require 'redux'
store = createStore reducer
console.assert unwrapState(store.getState()) is 0, 'initial state'
console.assert store.getState().url is '0', 'initial url '

store.dispatch actionCreators.handlePath '1'

console.assert unwrapState(store.getState()) is 1, 'state has changed after handlePath'
console.assert store.getState().url is '1', 'url has changed'
console.assert store.getState().createHistoryEntry is true, 'should create history entries by default'

store.dispatch actionCreators.backToPath '0'

console.assert unwrapState(store.getState()) is 0, 'state has changed after backToPath'
console.assert store.getState().url is '0', 'url has changed'
console.assert store.getState().createHistoryEntry is false, 'should not create history entry for a back action'

store.dispatch {type:'UNKNOWN'}

console.assert store.getState().createHistoryEntry is false, 'unchanged url shouldnt create history'
