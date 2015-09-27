React = require 'react'
{ Provider, connect } = require('react-redux')
{ createStore, applyMiddleware, combineReducers, bindActionCreators } = require('redux')
thunk = require('redux-thunk')

Counter = require('./Counter')
{ increment, decrement, setTo7, incrementIfOdd, incrementAsync } = Counter.actionCreators

QuestionList = require './QuestionList'
{ setText } = require('./Question').actionCreators

BranchingWizardStepA = require './BranchingWizardStepA'
{ b0, b1 } = BranchingWizardStepA.actionCreators
Wizard = require './Wizard'


# UI

App = React.createClass
  propTypes:
    counter: React.PropTypes.number.isRequired
    questions: React.PropTypes.array.isRequired
    wizardStep: React.PropTypes.string.isRequired

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

    <h1>Wizard step: {@props.wizardStep}</h1>
    { if @props.wizardStep is 'A'
        <div>
          <button onClick={() => @props.advance b0()}>Advance to B0</button>
          <button onClick={() => @props.advance b1()}>Advance to B1</button>
        </div>
      else
        <button onClick={@props.advance}>Advance</button> }

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


rootReducer = combineReducers
  counter: Counter.reducer
  questions: QuestionList.reducer
  wizardStep: Wizard.reducer

createStoreWithMiddleware = applyMiddleware(thunk)(createStore)
store = createStoreWithMiddleware rootReducer

mapStateToProps = ({counter, questions, wizardStep}) -> {counter, questions, wizardStep}

mapDispatchToProps = (dispatch) ->
  cs = bindActionCreators Counter.actionCreators, dispatch
  qs = bindActionCreators QuestionList.actionCreators, dispatch
  ws = bindActionCreators Wizard.actionCreators, dispatch
  return Object.assign {}, cs, qs, ws

ConnectedApp = connect(mapStateToProps, mapDispatchToProps)(App)

# INITIALISATION

store.dispatch QuestionList.actionCreators.append()
store.dispatch QuestionList.actionCreators.append()
store.dispatch QuestionList.actionCreators.modify 1, setText 'Hello'

React.render <Provider store={store}>{() -> <ConnectedApp />}</Provider>, document.getElementById('root')

