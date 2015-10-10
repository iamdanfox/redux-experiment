Counter = require './Counter'


prefixes = { 'NESTED$' }

extendAction = (key, value, action) ->
  extension = {}
  extension[key] = value
  return Object.assign {}, action, extension

unextendAction = (key, originalAction) ->
  action = Object.assign {}, originalAction
  extension = {}
  extension[key] = action[key]
  delete action[key]
  return {action, extension}

wrapAction = (action) -> Object.assign {}, action, {type: prefixes.NESTED$ + action.type}
# iff `action` was a wrapped action, return the inner action. (otherwise null)
unwrapAction = (action) ->
  if action.type.indexOf(prefixes.NESTED$) is -1
    return null

  return Object.assign {}, action, {type: action.type.substr prefixes.NESTED$.length}

wrapState = (state) -> {inner: state}
unwrapState = (state) -> state.inner



actionCreators =
  wrapped: (action, createHistoryEntry = true) ->
    if typeof action is 'function' # ie, redux-thunk
      return (realDispatch, realGetState) ->
        dispatch = (a) -> realDispatch extendAction 'createHistoryEntry', createHistoryEntry, wrapAction a
        getState = () -> unwrapState realGetState()
        action dispatch, getState
    else
      return extendAction 'createHistoryEntry', createHistoryEntry, wrapAction action

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
  actionAndExtension = unextendAction 'createHistoryEntry', unwrapAction(action) or {}
  innerState = Counter.reducer unwrapState(state), actionAndExtension.action
  newUrl = innerState.toString()
  createHistoryEntry = newUrl isnt state.url
  if actionAndExtension.extension.createHistoryEntry is false # actions can prevent history entries
    createHistoryEntry = false
  return Object.assign wrapState(innerState), {url: newUrl, createHistoryEntry}


module.exports = {actionCreators, reducer, unwrapState}

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
