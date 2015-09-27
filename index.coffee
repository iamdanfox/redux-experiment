React = require 'react'
{ Provider, connect } = require('react-redux')
{ createStore, applyMiddleware, combineReducers, bindActionCreators } = require('redux')
thunk = require('redux-thunk')

Counter = require('./Counter')
{ increment, decrement, setTo7, incrementIfOdd, incrementAsync } = Counter.actionCreators

QuestionList = require './QuestionList'
{ setText } = require('./Question').actionCreators


# UI

App = React.createClass
  propTypes:
    counter: React.PropTypes.number.isRequired
    questions: React.PropTypes.array.isRequired

  render: () ->
    <div>
    <p>
      Clicked: {@props.counter} times
      {' '}
      <button onClick={@props.increment}>+</button>
      {' '}
      <button onClick={@props.decrement}>-</button>
      {' '}
      <button onClick={@props.incrementIfOdd}>Increment if odd</button>
      {' '}
      <button onClick={() => @props.dispatch incrementAsync()}>Increment async</button>

      <button onClick={@props.setTo7}>Set to 7</button>
    </p>

    <h2>Questions</h2>
    <button onClick={@props.append}>Append</button>
    <ul>
    { @props.questions.map ({text, questionType}, index) =>
      <li>
        (Type: {questionType}),
        <input type= 'text' value={text} onChange={(e) => @props.modify index, setText e.target.value} />
        <button onClick={() => @props.delete index}>Delete</button>
      </li> }
    </ul>
    </div>


rootReducer = combineReducers {counter: Counter.reducer, questions: QuestionList.reducer}
createStoreWithMiddleware = applyMiddleware(thunk)(createStore)
store = createStoreWithMiddleware rootReducer

mapStateToProps = ({counter, questions}) -> {counter, questions}
mapDispatchToProps = (dispatch) ->
  cs = bindActionCreators Counter.actionCreators, dispatch
  qs = bindActionCreators QuestionList.actionCreators, dispatch
  return Object.assign {}, cs, qs, {dispatch}

ConnectedApp = connect(mapStateToProps, mapDispatchToProps)(App)

# INITIALISATION

store.dispatch QuestionList.actionCreators.append()
store.dispatch QuestionList.actionCreators.append()
store.dispatch QuestionList.actionCreators.modify 1, setText 'Hello'

React.render <Provider store={store}>{() -> <ConnectedApp />}</Provider>, document.getElementById('root')

