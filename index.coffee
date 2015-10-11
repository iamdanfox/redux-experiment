# augment reducer
HistoryAugmenter = require './router/HistoryAugmenter'
{ makeHistoryAware } = HistoryAugmenter
Routable = require './redux/RoutableTwoRoutableCounters'
{ reducer, actionCreators, unwrapState } = makeHistoryAware Routable.reducer

# set up middleware pipeline
{ createStore, applyMiddleware, compose } = require 'redux'
thunk = require 'redux-thunk'
logger = require 'redux-logger'
store = applyMiddleware(thunk, logger {collapsed: true})(createStore) reducer

RoutableTwoRoutableCounters = require './ui/RoutableTwoRoutableCounters'

# wire up to react
{ Provider, connect } = require 'react-redux'

stateToProps = (state) -> {reduxState: HistoryAugmenter.unwrapState state}
dispatchToProps = (dispatch) -> {dispatch: compose dispatch, HistoryAugmenter.actionCreators.historyEntry}
Connected = connect(stateToProps, dispatchToProps) RoutableTwoRoutableCounters
React = require 'react'
React.render (
  <Provider store={store}>{() -> <Connected />}</Provider>
), document.getElementById 'root'

# start router
{ startRouter } = require './router/MakeRouter'
startRouter
  store: store
  handlePopStatePath: compose(actionCreators.noHistoryEntry, Routable.actionCreators.handlePath)
  pathFromReduxState: (state) -> unwrapState(state).path
  fromBackButton: (state) -> state.fromBackButton
