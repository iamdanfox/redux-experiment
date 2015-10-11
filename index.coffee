{ createStore, applyMiddleware } = require('redux')
logger = require 'redux-logger'
thunk = require('redux-thunk')
{ reducer, actionCreators } = require './redux/RoutableTwoRoutableCounters'
UI = require './ui/RoutableTwoRoutableCounters'
React = require 'react'
{ Provider, connect } = require('react-redux')
Router = require './redux/Router'

store = applyMiddleware(thunk, logger {collapsed: true})(createStore) reducer

stateToProps = (reduxState) -> {reduxState}
dispatchToProps = (dispatch) -> {dispatch}
ConnectedUI = connect(stateToProps, dispatchToProps) UI

React.render (
  <Provider store={store}>
    {() -> <ConnectedUI />}
  </Provider>
), document.getElementById 'root'

Router store, actionCreators.backToPath
