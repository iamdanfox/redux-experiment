{ createStore, applyMiddleware, compose } = require 'redux'
thunk = require 'redux-thunk'
logger = require 'redux-logger'
makeBackButtonTracker = require './redux/BackButtonTracker'
Routable = require './redux/RoutableTwoRoutableCounters'
{ reducer, actionCreators, unwrapState } = makeBackButtonTracker Routable.reducer
UIComponent = require './ui/TwoRoutableCounters'
ReduxNest = require './ui/ReduxNest'
React = require 'react'
{ Provider, connect } = require 'react-redux'
Router = require './redux/Router'

store = applyMiddleware(thunk, logger {collapsed: true})(createStore) reducer

stateToProps = (reduxState) -> {reduxState: unwrapState reduxState}
dispatchToProps = (dispatch) -> {dispatch: compose dispatch, actionCreators.historyEntry}
RoutableComponent = ReduxNest
  inner: UIComponent
  unwrapState: Routable.unwrapState
  wrap: Routable.actionCreators.wrap

ConnectedUI = connect(stateToProps, dispatchToProps) RoutableComponent

React.render (
  <Provider store={store}>
    {() -> <ConnectedUI />}
  </Provider>
), document.getElementById 'root'

Router store, compose(actionCreators.noHistoryEntry, Routable.actionCreators.handlePath),
  url: (state) -> unwrapState(state).url
  pathChanged: (state) -> unwrapState(state).pathChanged
  fromBackButton: (state) -> state.fromBackButton


# require './redux/BackButtonTracker'
