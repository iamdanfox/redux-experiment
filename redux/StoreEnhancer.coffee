ThunkForwarder = require './ThunkForwarder'
{ prefix, unprefix } = require('./Prefixer')('fromBack$')

enhance = (innerReducer) ->
  throw "StoreEnhancer must be called with a reducer argument" unless typeof innerReducer is 'function'

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

  forward = (fromBackButton) -> (actionCreatorResult) ->
    ThunkForwarder(
      wrapAction: (action) -> extendAction {fromBackButton}, wrapAction action
      forwardGetState: unwrapState
    )(actionCreatorResult)

  actionCreators =
    historyEntry: forward false
    noHistoryEntry: forward true

  initialState = do ->
    innerInitialState = innerReducer undefined, {}
    return Object.assign {}, wrapState(innerInitialState), {fromBackButton: false}

  reducer = (state = initialState, action) ->
    actionAndExtension = unextendAction {'fromBackButton'}, unwrapAction(action) or {}
    innerState = innerReducer unwrapState(state), actionAndExtension.action
    fromBackButton = if actionAndExtension.extension.fromBackButton? then actionAndExtension.extension.fromBackButton else state.fromBackButton
    return Object.assign wrapState(innerState), {fromBackButton}

  return {actionCreators, reducer, unwrapState}


module.exports = enhance




# cheeky little unit tests
{ createStore, applyMiddleware } = require 'redux'
thunk = require 'redux-thunk'
# logger = require 'redux-logger'
createStoreWithMiddleware = applyMiddleware(thunk)(createStore)
someReducer = require('../redux/Counter').reducer
triple = enhance someReducer
store = createStoreWithMiddleware triple.reducer

console.assert store.getState().fromBackButton is false, 'no history entries initially!'

store.dispatch triple.actionCreators.noHistoryEntry {}
console.assert store.getState().fromBackButton, 'true is persisted'
console.assert triple.unwrapState(store.getState()) is someReducer(undefined, {}), 'contained redux store all happy'
