Counter = require './Counter'
ThunkForwarder = require './ThunkForwarder'
{ prefix, unprefix } = require('./Prefixer')('Rt$')


extendAction = (extension, action) ->
  prefixedExtension = {}
  for key,val of extension
    prefixedExtension[prefix key] = val
  return Object.assign {}, action, prefixedExtension
unextendAction = (extensionKeyObject, originalAction) ->
  action = Object.assign {}, originalAction
  extension = {}
  for key,val of extensionKeyObject
    extension[key] = action[prefix key]
  delete action[prefix key]
  return {action, extension}

wrapAction = (action) -> Object.assign {}, action, {type: prefix action.type}
unwrapAction = (action) ->
  return null unless (type = unprefix action.type)?
  return Object.assign {}, action, {type}

wrapState = (inner) -> {inner}
unwrapState = ({inner}) -> inner



actionCreators =
  forwardAction: (actionCreatorResult, fromBackButton = false) ->
    ThunkForwarder(
      forwardPlain: (action) -> extendAction {fromBackButton}, wrapAction action
      forwardDispatch: (realDispatch) -> (a) -> realDispatch extendAction {fromBackButton}, wrapAction a
      forwardGetState: (realGetState) -> () -> unwrapState realGetState()
    )(actionCreatorResult)

  handlePath: (path, fromBackButton = false) ->
    if path is '' # initial load
      initial = Counter.reducer undefined, {}
      return actionCreators.forwardAction Counter.actionCreators.set(initial), fromBackButton

    number = parseInt path, 10
    if isNaN(number) then number = Counter.reducer undefined, {}
    return actionCreators.forwardAction Counter.actionCreators.set(number), fromBackButton

  backToPath: (path) ->
    actionCreators.handlePath path, true


initialState = Object.assign wrapState(Counter.reducer undefined, {}), {url: undefined, fromBackButton: false, pathChanged: false}

reducer = (state = initialState, action) ->
  actionAndExtension = unextendAction {'fromBackButton'}, unwrapAction(action) or {}
  innerState = Counter.reducer unwrapState(state), actionAndExtension.action
  newUrl = innerState.toString()
  pathChanged = newUrl isnt state.url
  fromBackButton = if actionAndExtension.extension.fromBackButton? then actionAndExtension.extension.fromBackButton else state.fromBackButton
  return Object.assign wrapState(innerState), {url: newUrl, fromBackButton, pathChanged}


module.exports = {actionCreators, reducer, unwrapState}

# cheeky little unit tests

{ createStore } = require 'redux'
store = createStore reducer
console.assert unwrapState(store.getState()) is 0, 'initial state'
console.assert store.getState().url is '0', 'initial url '
console.assert store.getState().fromBackButton is false, 'initially not from back button'
console.assert store.getState().pathChanged is true, 'path did change initially'

store.dispatch actionCreators.handlePath 'broken'
console.assert store.getState().url is '0', 'broken url redirected to initial'

store.dispatch actionCreators.handlePath '1'

console.assert unwrapState(store.getState()) is 1, 'state has changed after handlePath'
console.assert store.getState().url is '1', 'url has changed'
console.assert store.getState().fromBackButton is false, 'again not from back button'
console.assert store.getState().pathChanged is true, 'path changed from 0 to 1'

store.dispatch actionCreators.backToPath '0'

console.assert unwrapState(store.getState()) is 0, 'state has changed after backToPath'
console.assert store.getState().url is '0', 'url has changed'
console.assert store.getState().fromBackButton, 'this time we did come from a back button'

store.dispatch actionCreators.backToPath '0'
console.assert store.getState().fromBackButton, 'more back button'
console.assert store.getState().pathChanged is false, 'path hasnt changed'

store.dispatch {type:'UNKNOWN'}

console.assert store.getState().fromBackButton, 'this reducer still thinks the most recent action was triggered by a back button'
console.assert store.getState().pathChanged is false, 'unchanged url shouldnt create history'
