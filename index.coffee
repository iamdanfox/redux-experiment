React = require 'react'
{ Provider, connect } = require('react-redux')
{ createStore, applyMiddleware, combineReducers, bindActionCreators } = require('redux')
thunk = require('redux-thunk')

# ACTIONS

INCREMENT_COUNTER = 'INCREMENT_COUNTER'
DECREMENT_COUNTER = 'DECREMENT_COUNTER'
SET_TO_7 = 'SET_TO_7'

# ACTION CREATORS

increment = () -> {type: INCREMENT_COUNTER}

decrement = () -> {type: DECREMENT_COUNTER}

setTo7 = () -> {type: SET_TO_7}

incrementIfOdd = () -> (dispatch, getState) ->
  if getState().counter % 2 is 0
    return

  dispatch increment()

incrementAsync = (delay = 1000) -> (dispatch) ->
  setTimeout (() ->
    dispatch increment()
  ), delay

# UI

Counter = React.createClass
  propTypes:
    increment: React.PropTypes.func.isRequired,
    incrementIfOdd: React.PropTypes.func.isRequired,
    incrementAsync: React.PropTypes.func.isRequired,
    decrement: React.PropTypes.func.isRequired,
    setTo7: React.PropTypes.func.isRequired,
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

mapStateToProps = ({counter}) -> {counter}

mapDispatchToProps = (dispatch) ->
  bindActionCreators { increment, decrement, incrementAsync, incrementIfOdd, setTo7 }, dispatch

App = connect(mapStateToProps, mapDispatchToProps)(Counter)

# REDUCERS

counter = (state = 0, action) ->
  switch action.type
    when INCREMENT_COUNTER then state + 1
    when DECREMENT_COUNTER then state - 1
    when SET_TO_7 then 7
    else state

rootReducer = combineReducers {counter}
createStoreWithMiddleware = applyMiddleware(thunk)(createStore)
store = createStoreWithMiddleware rootReducer

# INITIALISATION

React.render <Provider store={store}>{() -> <App />}</Provider>, document.getElementById('root')

