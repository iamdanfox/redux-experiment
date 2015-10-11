{ createStore, applyMiddleware, combineReducers, bindActionCreators } = require('redux')
logger = require 'redux-logger'
thunk = require('redux-thunk')

{ reducer } = require './redux/RoutableTwoRoutableCounters'
{ handlePath, backToPath } = require('./redux/RoutableTwoRoutableCounters').actionCreators
UI = require './ui/RoutableTwoRoutableCounters'

# INITIALIZATION =========================================

createStoreWithMiddleware = applyMiddleware(thunk, logger({collapsed: true}))(createStore)
store = createStoreWithMiddleware reducer
mapStateToProps = (reduxState) -> {reduxState}
mapDispatchToProps = (dispatch) -> {dispatch}

{ Provider, connect } = require('react-redux')
ConnectedUI = connect(mapStateToProps, mapDispatchToProps)(UI)

React = require 'react'
React.render <Provider store={store}>{() -> <ConnectedUI />}</Provider>, document.getElementById('root')

# ROUTING STUFF =========================================

dropFirstSlash = (path) -> path.substr 1
addFirstSlash = (path) -> '/' + path

unsubscribe = store.subscribe () ->
  { url, pathChanged, fromBackButton } = store.getState()
  if not pathChanged
    return # I'm not allowing discrete history steps within one URL!

  if fromBackButton
    return

  window.history.pushState null, null, addFirstSlash(url)

# do initial page load.
path = dropFirstSlash window.location.pathname
store.dispatch handlePath path

window.onpopstate = (e) ->
  # back button shouldn't insert a new history entry.
  path = dropFirstSlash window.location.pathname
  store.dispatch backToPath path
