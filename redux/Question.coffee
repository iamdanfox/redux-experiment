


actions = {'SET_TEXT', 'SET_QUESTION_TYPE'}

actionCreators =
  setText: (text) -> {type: actions.SET_TEXT, text}
  setQuestionType: (questionType) -> {type: actions.SET_QUESTION_TYPE, questionType}

reducer = (state = {text: '', questionType: 0}, action) ->
  switch action.type
    when actions.SET_TEXT then Object.assign {}, state, text: action.text
    when actions.SET_QUESTION_TYPE then Object.assign {}, state, questionType: action.questionType
    else state

module.exports = {actions, actionCreators, reducer}


# cheeky little unit tests

{ createStore } = require 'redux'
store = createStore reducer
console.assert store.getState().text is '', 'initial text empty'
console.assert store.getState().questionType is 0, 'initial type 0'

store.dispatch actionCreators.setText 'Hello'
console.assert store.getState().text is 'Hello'
store.dispatch actionCreators.setQuestionType 1
console.assert store.getState().questionType is 1
