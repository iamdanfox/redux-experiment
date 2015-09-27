React = require 'react'
{ Provider, connect } = require('react-redux')
{ createStore, applyMiddleware, combineReducers, bindActionCreators } = require('redux')
thunk = require('redux-thunk')
QuestionList = require './QuestionList'
Question = require './Question'

# ACTIONS

INCREMENT_COUNTER = 'INCREMENT_COUNTER'
DECREMENT_COUNTER = 'DECREMENT_COUNTER'
SET_TO_7 = 'SET_TO_7'

# REDUCERS

counter = (state = 0, action) ->
  switch action.type
    when INCREMENT_COUNTER then state + 1
    when DECREMENT_COUNTER then state - 1
    when SET_TO_7 then 7
    else state

rootReducer = combineReducers {counter, questions: QuestionList.reducer}
createStoreWithMiddleware = applyMiddleware(thunk)(createStore)
store = createStoreWithMiddleware rootReducer

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
    counter: React.PropTypes.number.isRequired
    questions: React.PropTypes.array.isRequired

  render: () ->
    <div>
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

    <h2>Questions</h2>
    <button onClick={() => @props.dispatch QuestionList.actionCreators.append()}>Append</button>
    <ul>
    { @props.questions.map ({text, questionType}, index) =>
      <li>
        (Type: {questionType}),
        <input type= 'text' value={text} onChange={(e) =>
        @props.dispatch QuestionList.actionCreators.modify index, Question.actionCreators.setText e.target.value} />
        <button onClick={() => @props.dispatch QuestionList.actionCreators.delete index}>Delete</button>
      </li> }
    </ul>
    </div>

mapStateToProps = ({counter, questions}) -> {counter, questions}
mapDispatchToProps = (dispatch) -> {dispatch}
App = connect(mapStateToProps, mapDispatchToProps)(Counter)

# INITIALISATION

store.dispatch QuestionList.actionCreators.append()
store.dispatch QuestionList.actionCreators.append()
store.dispatch QuestionList.actionCreators.modify 1, Question.actionCreators.setText 'Hello'

React.render <Provider store={store}>{() -> <App />}</Provider>, document.getElementById('root')

