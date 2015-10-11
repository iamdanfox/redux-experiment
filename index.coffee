


{ createStore, applyMiddleware, combineReducers, bindActionCreators } = require('redux')
logger = require 'redux-logger'
thunk = require('redux-thunk')
createStoreWithMiddleware = applyMiddleware(thunk, logger({collapsed: true}))(createStore)
# createStoreWithMiddleware = applyMiddleware(thunk)(createStore)


TwoRoutableCounters = require './redux/TwoRoutableCounters.coffee'
RoutableCounter = require './redux/RoutableCounter'
store = createStoreWithMiddleware RoutableCounter.reducer



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
store.dispatch RoutableCounter.actionCreators.handlePath path

window.onpopstate = (e) ->
  # back button shouldn't insert a new history entry.
  path = dropFirstSlash window.location.pathname
  store.dispatch RoutableCounter.actionCreators.backToPath path



mapStateToProps = (state) -> {reduxState: RoutableCounter.unwrapState state}
mapDispatchToProps = (realDispatch) ->
  return {
    dispatch: (action) -> realDispatch RoutableCounter.actionCreators.forwardAction action
  }

CounterUI = require './ui/Counter'
{ Provider, connect } = require('react-redux')
ConnectedApp = connect(mapStateToProps, mapDispatchToProps)(CounterUI)

React = require 'react'
React.render <Provider store={store}>{() -> <ConnectedApp />}</Provider>, document.getElementById('root')
