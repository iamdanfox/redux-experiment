React = require 'react'
{ createStore, applyMiddleware, combineReducers, bindActionCreators } = require('redux')
{ Provider, connect } = require('react-redux')
thunk = require('redux-thunk')
logger = require 'redux-logger'

Counter = require './redux/Counter'
RoutableCounter = require './redux/RoutableCounter'
{ increment, decrement, setTo7, incrementIfOdd, incrementAsync } = Counter.actionCreators
{ wrapped } = RoutableCounter.actionCreators

# UI

App = React.createClass
  propTypes:
    counter: React.PropTypes.number.isRequired
    dispatch: React.PropTypes.func.isRequired

  render: () ->
    <p>
      Clicked: {@props.counter} times
      {' '}
      <button onClick={() => @props.dispatch increment()}>+</button>
      {' '}
      <button onClick={() => @props.dispatch decrement()}>-</button>
      {' '}
      <button onClick={() => @props.dispatch incrementIfOdd()}>Increment if odd</button>
      {' '}
      <button onClick={() => @props.dispatch incrementAsync()}>Increment async</button>

      <button onClick={() => @props.dispatch setTo7()}>Set to 7</button>
    </p>


# rootReducer = combineReducers
#   counter: RoutableCounter.reducer

createStoreWithMiddleware = applyMiddleware(thunk, logger())(createStore)
# createStoreWithMiddleware = applyMiddleware(thunk)(createStore)
store = createStoreWithMiddleware RoutableCounter.reducer



dropFirstSlash = (path) -> path.substr 1
addFirstSlash = (path) -> '/' + path

# prevUrl = store.getState().url
unsubscribe = store.subscribe () ->
  newUrl = store.getState().url
  # if prevUrl isnt newUrl
  window.history.replaceState null, null, addFirstSlash(newUrl)
  # prevUrl = newUrl



handlePath = () ->
  url = dropFirstSlash window.location.pathname
  store.dispatch RoutableCounter.actionCreators.handleUrl url

handlePath()
window.onpopstate = (e) ->
  handlePath()



mapStateToProps = ({wrappedState}) -> {counter: wrappedState}
mapDispatchToProps = (realDispatch) ->
  dispatch: (action) -> realDispatch wrapped action

ConnectedApp = connect(mapStateToProps, mapDispatchToProps)(App)

React.render <Provider store={store}>{() -> <ConnectedApp />}</Provider>, document.getElementById('root')
