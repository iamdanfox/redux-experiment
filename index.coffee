{ createStore, applyMiddleware } = require 'redux'
thunk = require 'redux-thunk'
logger = require 'redux-logger'
{ reducer, actionCreators, unwrapState } = require './redux/RoutableTwoRoutableCounters'
UI = require './ui/TwoRoutableCounters'
ReduxNest = require './ui/ReduxNest'
React = require 'react'
{ Provider, connect } = require 'react-redux'
Router = require './redux/Router'

store = applyMiddleware(thunk, logger {collapsed: true})(createStore) reducer

stateToProps = (reduxState) -> {reduxState}
dispatchToProps = (dispatch) -> {dispatch}
RoutableComponent = ReduxNest UI, unwrapState, actionCreators.forwardAction
ConnectedUI = connect(stateToProps, dispatchToProps) RoutableComponent

React.render (
  <Provider store={store}>
    {() -> <ConnectedUI />}
  </Provider>
), document.getElementById 'root'

Router store, actionCreators.backToPath
