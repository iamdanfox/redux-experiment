{ createStore, applyMiddleware, combineReducers, bindActionCreators } = require('redux')
logger = require 'redux-logger'
thunk = require('redux-thunk')
createStoreWithMiddleware = applyMiddleware(thunk, logger({collapsed: true}))(createStore)
# createStoreWithMiddleware = applyMiddleware(thunk)(createStore)

RoutableTwoRoutableCounters = require './redux/RoutableTwoRoutableCounters'
store = createStoreWithMiddleware RoutableTwoRoutableCounters.reducer

# ROUTING STUFF =========================================

dropFirstSlash = (path) -> path.substr 1
addFirstSlash = (path) -> '/' + path

unsubscribe = store.subscribe () ->
  { url, createHistoryEntry } = store.getState()
  if not createHistoryEntry
    return

  window.history.pushState null, null, addFirstSlash(url)

# do initial page load.
path = dropFirstSlash window.location.pathname
store.dispatch RoutableTwoRoutableCounters.actionCreators.handlePath path

window.onpopstate = (e) ->
  # back button shouldn't insert a new history entry.
  path = dropFirstSlash window.location.pathname
  store.dispatch RoutableTwoRoutableCounters.actionCreators.backToPath path


mapStateToProps = (reduxState) -> {reduxState}
mapDispatchToProps = (dispatch) -> {dispatch}

UI = require './ui/RoutableTwoRoutableCounters'
{ Provider, connect } = require('react-redux')
ConnectedUI = connect(mapStateToProps, mapDispatchToProps)(UI)

React = require 'react'
React.render <Provider store={store}>{() -> <ConnectedUI />}</Provider>, document.getElementById('root')
