{ createStore, applyMiddleware, compose } = require 'redux'
thunk = require 'redux-thunk'
logger = require 'redux-logger'
StoreEnhancer = require './redux/StoreEnhancer'
Routable = require './redux/RoutableTwoRoutableCounters'
{ reducer, actionCreators, unwrapState } = StoreEnhancer Routable.reducer
UI = require './ui/TwoRoutableCounters'
ReduxNest = require './ui/ReduxNest'
React = require 'react'
{ Provider, connect } = require 'react-redux'
Router = require './redux/Router'

store = applyMiddleware(thunk, logger {collapsed: true})(createStore) reducer

stateToProps = (reduxState) -> {reduxState: unwrapState reduxState}
dispatchToProps = (dispatch) -> {dispatch: compose dispatch, actionCreators.historyEntry}
RoutableComponent = ReduxNest
  inner: UI
  unwrapState: Routable.unwrapState
  forwardAction: Routable.actionCreators.forwardAction

ConnectedUI = connect(stateToProps, dispatchToProps) RoutableComponent

React.render (
  <Provider store={store}>
    {() -> <ConnectedUI />}
  </Provider>
), document.getElementById 'root'

Router store, compose(actionCreators.noHistoryEntry, Routable.actionCreators.backToPath),
  url: (state) -> unwrapState(state).url
  pathChanged: (state) -> unwrapState(state).pathChanged
  fromBackButton: (state) -> state.fromBackButton


# require './redux/StoreEnhancer'
