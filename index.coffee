# augment reducer
{ makeHistoryAware, reactUtils } = require './router/MakeHistoryAware'
Routable = require './redux/RoutableTwoRoutableCounters'
{ reducer, actionCreators, unwrapState } = makeHistoryAware Routable.reducer

# set up middleware pipeline
{ createStore, applyMiddleware, compose } = require 'redux'
thunk = require 'redux-thunk'
logger = require 'redux-logger'
store = applyMiddleware(thunk, logger {collapsed: true})(createStore) reducer

# hide some routing related stuff from react
ReduxNest = require './ui/ReduxNest'
RoutableHistoryAwareComponent = ReduxNest
  inner: require './ui/TwoRoutableCounters'
  unwrapState: Routable.unwrapState
  wrap: Routable.actionCreators.wrap

# wire up to react
{ Provider, connect } = require 'react-redux'
ConnectedRoutableHistoryAwareComponent = connect(reactUtils.stateToProps, reactUtils.dispatchToProps) RoutableHistoryAwareComponent
React = require 'react'
React.render (
  <Provider store={store}>
    {() -> <ConnectedRoutableHistoryAwareComponent />}
  </Provider>
), document.getElementById 'root'

# start router
{ startRouter } = require './router/MakeRouter'
startRouter
  store: store
  handlePopStatePath: compose(actionCreators.noHistoryEntry, Routable.actionCreators.handlePath)
  pathFromReduxState: (state) -> unwrapState(state).path
  fromBackButton: (state) -> state.fromBackButton
