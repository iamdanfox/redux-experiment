{ compose } = require 'redux'
ThunkForwarder = require './ThunkForwarder'
HistoryEntryPrefixer = require('./Prefixer')('history$')
NoHistoryPrefixer = require('./Prefixer')('nohistory$')
prefixExtensionKey = require('./Prefixer')('historyAware$').prefix


extendAction = (extension) -> (action) ->
  prefixedExtension = {}
  for key,val of extension
    prefixedExtension[prefixExtensionKey key] = val
  return Object.assign {}, action, prefixedExtension
unextendAction = (extensionKeyObject, originalAction) ->
  action = Object.assign {}, originalAction
  extension = {}
  for key,val of extensionKeyObject
    extension[key] = action[prefixExtensionKey key]
  delete action[prefixExtensionKey key]
  return {action, extension}

wrapState = (inner) -> {inner}
unwrapState = ({inner}) -> inner

actionCreators =
  historyEntry:  (actionCreatorResult) ->
    wrapAction = (action) -> Object.assign {}, action, {type: HistoryEntryPrefixer.prefix action.type}
    ThunkForwarder(
      wrapAction: compose extendAction({fromBackButton: false}), wrapAction
      unwrapState: unwrapState
    )(actionCreatorResult)

  noHistoryEntry:  (actionCreatorResult) ->
    wrapAction = (action) -> Object.assign {}, action, {type: NoHistoryPrefixer.prefix action.type}
    ThunkForwarder(
      wrapAction: compose extendAction({fromBackButton: true}), wrapAction
      unwrapState: unwrapState
    )(actionCreatorResult)

reactUtils =
  stateToProps: (reduxState) -> {reduxState: unwrapState reduxState}
  dispatchToProps: (dispatch) -> {dispatch: compose dispatch, actionCreators.historyEntry}

makeBackButtonAware = (innerReducer) ->
  throw "BackButtonAware must be called with a reducer argument" unless typeof innerReducer is 'function'

  initialState = do ->
    innerInitialState = innerReducer undefined, {}
    return Object.assign {}, wrapState(innerInitialState), {fromBackButton: false}

  reducer = (state = initialState, action) ->
    unwrapForwardAction = (action) ->
      return null unless (type = HistoryEntryPrefixer.unprefix action.type)?
      return Object.assign {}, action, {type}

    unwrapBackAction = (action) ->
      return null unless (type = NoHistoryPrefixer.unprefix action.type)?
      return Object.assign {}, action, {type}

    if (a = unwrapForwardAction action)
      innerState = innerReducer unwrapState(state), a
      return Object.assign wrapState(innerState), {fromBackButton: false}

    if (a = unwrapBackAction action)
      innerState = innerReducer unwrapState(state), a
      return Object.assign wrapState(innerState), {fromBackButton: true}

    return state

  return {actionCreators, reducer, unwrapState}


module.exports = { makeBackButtonAware, reactUtils }




# cheeky little unit tests
{ createStore, applyMiddleware } = require 'redux'
thunk = require 'redux-thunk'
createStoreWithMiddleware = applyMiddleware(thunk)(createStore)
# createStoreWithMiddleware = applyMiddleware(thunk, require('redux-logger')())(createStore)
someReducer = require('../redux/Counter').reducer
triple = makeBackButtonAware someReducer
store = createStoreWithMiddleware triple.reducer

console.assert store.getState().fromBackButton is false, 'no history entries initially!'

store.dispatch triple.actionCreators.noHistoryEntry {type:'FAKE'}

console.assert store.getState().fromBackButton, 'noHistory entry should be saved in fromBackButton'
console.assert triple.unwrapState(store.getState()) is someReducer(undefined, {}), 'contained redux store all happy'
