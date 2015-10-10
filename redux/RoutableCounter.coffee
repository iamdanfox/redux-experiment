Counter = require './Counter'


prefixes = { 'Rt$' }

prefix = (string) -> prefixes.Rt$ + string
unprefix = (prefixedString) ->
  if prefixedString.indexOf(prefixes.Rt$) is -1
    return null
  return prefixedString.substr prefixes.Rt$.length

console.assert prefix('a') is 'Rt$a', 'should add prefix correctly'
console.assert unprefix('Rt$a') is 'a', 'should remove prefix correctly'
console.assert unprefix('JKJADLJa') is null, 'shouldnt remove non prefix'


extendAction = (key, value, action) ->
  extension = {}
  extension[prefix key] = value
  return Object.assign {}, action, extension
unextendAction = (key, originalAction) ->
  action = Object.assign {}, originalAction
  extension = {}
  extension[key] = action[prefix key]
  delete action[prefix key]
  return {action, extension}

wrapAction = (action) -> Object.assign {}, action, {type: prefix action.type}
unwrapAction = (action) ->
  return null unless (type = unprefix action.type)?
  return Object.assign {}, action, {type}

wrapState = (state) -> {inner: state}
unwrapState = (state) -> state.inner



actionCreators =
  forwardAction: (action, createHistoryEntry = true) ->
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
      return actionCreators.forwardAction Counter.actionCreators.set(initial), createHistoryEntry

    number = parseInt path, 10
    return actionCreators.forwardAction Counter.actionCreators.set(number), createHistoryEntry

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
