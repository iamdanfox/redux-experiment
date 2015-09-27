React = require 'react'
{ Provider, connect } = require('react-redux')
{ createStore, applyMiddleware, combineReducers, bindActionCreators } = require('redux')
thunk = require('redux-thunk')

Counter = require('./redux/Counter')
{ increment, decrement, setTo7, incrementIfOdd, incrementAsync } = Counter.actionCreators

ForWho = require './redux/ForWho'

QuestionList = require './redux/QuestionList'
{ setText } = require('./redux/Question').actionCreators

BranchingWizardStepA = require './redux/BranchingWizardStepA'
{ b0, b1 } = BranchingWizardStepA.actionCreators
Wizard = require './redux/Wizard'


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
      <button onClick={() => @props.incrementAsync()}>Increment async</button>

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

    <h2>For Who Step</h2>
    <p>Perform an action and get launched into another wizard step</p>
    <button onClick={@props.forMe}>For me</button>
    <button onClick={@props.forSomeoneElse}>For someone else</button>

    <h2>Questions Step</h2>
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
  forWho: ForWho.reducer

createStoreWithMiddleware = applyMiddleware(thunk)(createStore)
store = createStoreWithMiddleware rootReducer

mapStateToProps = ({counter, questions, wizardStep, forWho}) -> {counter, questions, wizardStep, forWho}

mapDispatchToProps = (dispatch) ->
  cs = bindActionCreators Counter.actionCreators, dispatch
  qs = bindActionCreators QuestionList.actionCreators, dispatch
  ws = bindActionCreators Wizard.actionCreators, dispatch
  fs = bindActionCreators ForWho.actionCreators, dispatch
  return Object.assign {}, cs, qs, ws, fs

ConnectedApp = connect(mapStateToProps, mapDispatchToProps)(App)

# INITIALISATION

store.dispatch QuestionList.actionCreators.append()
store.dispatch QuestionList.actionCreators.append()
store.dispatch QuestionList.actionCreators.modify 1, setText 'Hello'

React.render <Provider store={store}>{() -> <ConnectedApp />}</Provider>, document.getElementById('root')

