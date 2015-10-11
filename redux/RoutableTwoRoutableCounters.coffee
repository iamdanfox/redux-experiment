TwoRoutableCounters = require './TwoRoutableCounters'
RoutableCounter = require './RoutableCounter'
# ThunkForwarder = require './ThunkForwarder'
{ prefix, unprefix } = require('./Prefixer')('Rt$')





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

wrapState = (inner) -> {inner}
unwrapState = ({inner}) -> inner



actionCreators =
  forwardAction: RoutableCounter.actionCreators.forwardAction

  handlePath: (path, createHistoryEntry = true) ->
    [leftPath, rightPath] = path.split /\//
    return actionCreators.forwardAction TwoRoutableCounters.actionCreators.left(RoutableCounter.handlePath leftPath), createHistoryEntry

  backToPath: (path) ->
    actionCreators.handlePath path, false


lrRoutables = (innerState) ->
  leftRoutable = TwoRoutableCounters.unwrapState(TwoRoutableCounters.sides.left, innerState)
  rightRoutable = TwoRoutableCounters.unwrapState(TwoRoutableCounters.sides.right, innerState)
  return {leftRoutable, rightRoutable}

pathFromRoutables = ({leftRoutable, rightRoutable}) -> "#{leftRoutable.url}/#{rightRoutable.url}"
createHistoryEntryFromRoutables = ({leftRoutable, rightRoutable}) -> leftRoutable.createHistoryEntry or rightRoutable.createHistoryEntry

initialState = do ->
  innerInitialState = TwoRoutableCounters.reducer undefined, {}
  routables = lrRoutables innerInitialState
  return Object.assign {}, wrapState(innerInitialState), {
    url: pathFromRoutables routables,
    createHistoryEntry: createHistoryEntryFromRoutables routables
  }

reducer = (state = initialState, action) ->
  actionAndExtension = unextendAction 'createHistoryEntry', unwrapAction(action) or {}
  innerState = TwoRoutableCounters.reducer unwrapState(state), actionAndExtension.action
  routables = lrRoutables innerState
  newUrl = pathFromRoutables routables

  createHistoryEntry = newUrl isnt state.url
  if createHistoryEntryFromRoutables(routables) is false # actions can prevent history entries
    createHistoryEntry = false
  return Object.assign wrapState(innerState), {url: newUrl, createHistoryEntry}


module.exports = {actionCreators, reducer, unwrapState}

# cheeky little unit tests
{ createStore, applyMiddleware } = require 'redux'
thunk = require 'redux-thunk'
createStoreWithMiddleware = applyMiddleware(thunk)(createStore)
store = createStoreWithMiddleware reducer

# console.assert unwrapState(store.getState()) is 0, 'initial state'
# console.assert store.getState().url is '0', 'initial url '
#
# store.dispatch actionCreators.handlePath '1'
#
# console.assert unwrapState(store.getState()) is 1, 'state has changed after handlePath'
# console.assert store.getState().url is '1', 'url has changed'
# console.assert store.getState().createHistoryEntry is true, 'should create history entries by default'
#
# store.dispatch actionCreators.backToPath '0'
#
# console.assert unwrapState(store.getState()) is 0, 'state has changed after backToPath'
# console.assert store.getState().url is '0', 'url has changed'
# console.assert store.getState().createHistoryEntry is false, 'should not create history entry for a back action'
#
# store.dispatch {type:'UNKNOWN'}
#
# console.assert store.getState().createHistoryEntry is false, 'unchanged url shouldnt create history'
