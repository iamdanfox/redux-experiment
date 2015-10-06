React = require 'react'
{ createStore, applyMiddleware, combineReducers, bindActionCreators } = require('redux')
{ Provider, connect } = require('react-redux')
thunk = require('redux-thunk')
logger = require 'redux-logger'

Counter = require('./redux/Counter')
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
      <button onClick={@props.increment}>+</button>
      {' '}
      <button onClick={@props.decrement}>-</button>
      {' '}
      <button onClick={@props.incrementIfOdd}>Increment if odd</button>
      {' '}
      <button onClick={() => @props.incrementAsync()}>Increment async</button>

      <button onClick={@props.setTo7}>Set to 7</button>
    </p>


rootReducer = combineReducers
  counter: Counter.reducer

createStoreWithMiddleware = applyMiddleware(thunk, logger())(createStore)
store = createStoreWithMiddleware rootReducer

mapStateToProps = (state) -> state

mapDispatchToProps = (dispatch) ->
  cs = bindActionCreators Counter.actionCreators, dispatch
  return Object.assign {}, cs

ConnectedApp = connect(mapStateToProps, mapDispatchToProps)(App)

React.render <Provider store={store}>{() -> <ConnectedApp />}</Provider>, document.getElementById('root')
