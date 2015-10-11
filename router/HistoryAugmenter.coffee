{ compose } = require 'redux'
NestThunkCreator = require '../nest/NestThunkCreator'
HistoryEntryPrefixer = require('../nest/MakePrefixer')('History-')
NoHistoryPrefixer = require('../nest/MakePrefixer')('NoHistory-')
{ wrapState, unwrapState, wrapAction, unwrapAction } = require '../nest/Wrappers'


makeHistoryAugmenter = ({nestActionCreator}) ->
  return {
    unwrapState: unwrapState

    makeActionCreators: () ->
      historyEntry: nestActionCreator {unwrapState, wrapAction: wrapAction(HistoryEntryPrefixer.prefix)}
      noHistoryEntry: nestActionCreator {unwrapState, wrapAction: wrapAction(NoHistoryPrefixer.prefix)}

    extendReducer: (innerReducer) ->
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
  }

historyAugmenter = makeHistoryAugmenter
  nestActionCreator: NestThunkCreator

augment = (innerReducer) ->
  unwrapState: historyAugmenter.unwrapState
  actionCreators: historyAugmenter.makeActionCreators()
  reducer: historyAugmenter.extendReducer innerReducer


module.exports = { makeHistoryAugmenter, historyAugmenter, augment }




# cheeky little unit tests
{ createStore, applyMiddleware } = require 'redux'
thunk = require 'redux-thunk'
createStoreWithMiddleware = applyMiddleware(thunk)(createStore)
# createStoreWithMiddleware = applyMiddleware(thunk, require('redux-logger')())(createStore)
someReducer = require('../redux/Counter').reducer
actionCreators = historyAugmenter.makeActionCreators()
unwrapState = historyAugmenter.unwrapState
reducer = historyAugmenter.extendReducer someReducer
store = createStoreWithMiddleware reducer

console.assert store.getState().fromBackButton is false, 'no history entries initially!'

store.dispatch actionCreators.noHistoryEntry {type:'FAKE'}

console.assert store.getState().fromBackButton, 'noHistory entry should be saved in fromBackButton'
console.assert unwrapState(store.getState()) is someReducer(undefined, {}), 'contained redux store all happy'
