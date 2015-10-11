{ compose } = require 'redux'
NestThunkCreator = require '../nest/NestThunkCreator'
HistoryEntryPrefixer = require('../nest/MakePrefixer')('History-')
NoHistoryPrefixer = require('../nest/MakePrefixer')('NoHistory-')
{ wrapState, unwrapState, wrapAction, unwrapAction } = require '../nest/Wrappers'


actionCreators =
  historyEntry: NestThunkCreator {unwrapState, wrapAction: wrapAction(HistoryEntryPrefixer.prefix)}
  noHistoryEntry: NestThunkCreator {unwrapState, wrapAction: wrapAction(NoHistoryPrefixer.prefix)}

makeHistoryAware = (innerReducer) ->
  throw "HistoryAware must be called with a reducer argument" unless typeof innerReducer is 'function'

  initialState = do ->
    innerInitialState = innerReducer undefined, {}
    return Object.assign {}, wrapState(innerInitialState), {fromBackButton: false}

  reduceInnerState = (state, unwrappedAction) ->
    return wrapState innerReducer unwrapState(state), unwrappedAction

  reducer = (state = initialState, action) ->
    if a = unwrapAction(HistoryEntryPrefixer.unprefix) action
      return Object.assign {}, reduceInnerState(state, a), {fromBackButton: false}
    else if a = unwrapAction(NoHistoryPrefixer.unprefix) action
      return Object.assign {}, reduceInnerState(state, a), {fromBackButton: true}
    else
      return state

  return {actionCreators, reducer, unwrapState}


module.exports = { makeHistoryAware, actionCreators, unwrapState }




# cheeky little unit tests
{ createStore, applyMiddleware } = require 'redux'
thunk = require 'redux-thunk'
createStoreWithMiddleware = applyMiddleware(thunk)(createStore)
# createStoreWithMiddleware = applyMiddleware(thunk, require('redux-logger')())(createStore)
someReducer = require('../redux/Counter').reducer
triple = makeHistoryAware someReducer
store = createStoreWithMiddleware triple.reducer

console.assert store.getState().fromBackButton is false, 'no history entries initially!'

store.dispatch triple.actionCreators.noHistoryEntry {type:'FAKE'}

console.assert store.getState().fromBackButton, 'noHistory entry should be saved in fromBackButton'
console.assert triple.unwrapState(store.getState()) is someReducer(undefined, {}), 'contained redux store all happy'
