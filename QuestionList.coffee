Question = require './Question'

actions = {'APPEND', 'DELETE', 'MODIFY'}

actionCreators =
  append: () -> {type: actions.APPEND}
  delete: (index) -> {type: actions.DELETE, index}
  modify: (index, questionAction) -> {type: actions.MODIFY, index, questionAction}

reducer = (state = [], action) ->
  switch action.type
    when actions.APPEND
      initialQuestionState = Question.reducer undefined, {}
      state.concat [initialQuestionState]

    when actions.DELETE
      clonedState = state.slice()
      clonedState.splice action.index, 1
      clonedState

    when actions.MODIFY
      clonedState = state.slice()
      clonedState[action.index] = Question.reducer clonedState[action.index], action.questionAction
      clonedState

    else state

module.exports = {actions, actionCreators, reducer}




# cheeky little unit tests

{ createStore } = require 'redux'
store = createStore reducer
console.assert store.getState().length is 0, 'hold 0 questions initially'

store.dispatch actionCreators.append()
store.dispatch actionCreators.append()
console.assert store.getState().length is 2, 'append increases length'

store.dispatch actionCreators.modify 0, Question.actionCreators.setText 'Hello'
store.dispatch actionCreators.delete(1)
console.assert store.getState().length is 1, 'delete last should leave first untouched'
console.assert store.getState()[0].text is 'Hello', 'MODIFY should delegate nicely'

store.dispatch actionCreators.delete(0)
console.assert store.getState().length is 0, 'delete decreases length'
