# augment reducer
{ makeBackButtonAware, reactUtils } = require './redux/BackButtonAware'
Routable = require './redux/RoutableTwoRoutableCounters'
{ reducer, actionCreators, unwrapState } = makeBackButtonAware Routable.reducer

# set up middleware pipeline
{ createStore, applyMiddleware, compose } = require 'redux'
thunk = require 'redux-thunk'
logger = require 'redux-logger'
store = applyMiddleware(thunk, logger {collapsed: true})(createStore) reducer

# hide some routing related stuff from react
ReduxNest = require './ui/ReduxNest'
RoutableBackButtonAwareComponent = ReduxNest
  inner: require './ui/TwoRoutableCounters'
  unwrapState: Routable.unwrapState
  wrap: Routable.actionCreators.wrap

# wire up to react
{ Provider, connect } = require 'react-redux'
ConnectedRoutableBackButtonAwareComponent = connect(reactUtils.stateToProps, reactUtils.dispatchToProps) RoutableBackButtonAwareComponent
React = require 'react'
React.render (
  <Provider store={store}>
    {() -> <ConnectedRoutableBackButtonAwareComponent />}
  </Provider>
), document.getElementById 'root'

# start router
{ startRouter } = require './redux/Router'
startRouter
  store: store
  handlePopStatePath: compose(actionCreators.noHistoryEntry, Routable.actionCreators.handlePath)
  pathFromReduxState: (state) -> unwrapState(state).url
  pathChanged: (state) -> unwrapState(state).pathChanged
  fromBackButton: (state) -> state.fromBackButton
