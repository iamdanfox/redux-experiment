# augment app
HistoryAugmenter = require './router/HistoryAugmenter'
App = require './redux/RoutableTwoRoutableCounters'
HistoryAugmentedApp = HistoryAugmenter.augment App.reducer


# set up middleware pipeline
{ createStore, applyMiddleware, compose } = require 'redux'
thunk = require 'redux-thunk'
logger = require 'redux-logger'
store = applyMiddleware(thunk, logger {collapsed: true})(createStore) HistoryAugmentedApp.reducer


# wire up to react
AppUI = require './ui/RoutableTwoRoutableCounters'
{ Provider, connect } = require 'react-redux'
stateToProps = (state) -> {reduxState: HistoryAugmentedApp.unwrapState state}
dispatchToProps = (dispatch) -> {dispatch: compose dispatch, HistoryAugmentedApp.actionCreators.historyEntry}
ConnectedAppUI = connect(stateToProps, dispatchToProps) AppUI
React = require 'react'
React.render (
  <Provider store={store}>{() -> <ConnectedAppUI />}</Provider>
), document.getElementById 'root'


# start router
{ startRouter } = require './router/MakeRouter'
startRouter
  store: store
  handlePopStatePath: compose(HistoryAugmentedApp.actionCreators.noHistoryEntry, App.actionCreators.handlePath)
  pathFromReduxState: (state) -> HistoryAugmentedApp.unwrapState(state).path
  fromBackButton: (state) -> state.fromBackButton
