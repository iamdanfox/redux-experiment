React = require 'react'
{ createStore, applyMiddleware, combineReducers, bindActionCreators } = require('redux')
{ Provider, connect } = require('react-redux')
thunk = require('redux-thunk')
logger = require 'redux-logger'

Counter = require './redux/Counter'
RoutableCounter = require './redux/RoutableCounter'
{ increment, decrement, setTo7, incrementIfOdd, incrementAsync } = Counter.actionCreators

# UI

App = React.createClass
  propTypes:
    counter: React.PropTypes.number.isRequired

  render: () ->
    <p>
      Clicked: {@props.counter} times
      {' '}
      <button onClick={() => @props.wrapped increment()}>+</button>
      {' '}
      <button onClick={() => @props.wrapped decrement()}>-</button>
      {' '}
      <button onClick={() => @props.wrapped incrementIfOdd()}>Increment if odd</button>
      {' '}
      <button onClick={() => @props.wrapped incrementAsync()}>Increment async</button>

      <button onClick={() => @props.wrapped setTo7()}>Set to 7</button>
    </p>


# rootReducer = combineReducers
#   counter: RoutableCounter.reducer

createStoreWithMiddleware = applyMiddleware(thunk, logger())(createStore)
store = createStoreWithMiddleware RoutableCounter.reducer


prevUrl = store.getState().url
unsubscribe = store.subscribe () ->
  newUrl = store.getState().url
  if prevUrl isnt newUrl
    console.log 'pushState', newUrl
    window.history.pushState null, null, newUrl
  prevUrl = newUrl















mapStateToProps = ({wrappedState}) -> {counter: wrappedState}

mapDispatchToProps = (dispatch) ->
  cs = bindActionCreators RoutableCounter.actionCreators, dispatch
  return Object.assign {}, cs

ConnectedApp = connect(mapStateToProps, mapDispatchToProps)(App)

React.render <Provider store={store}>{() -> <ConnectedApp />}</Provider>, document.getElementById('root')
