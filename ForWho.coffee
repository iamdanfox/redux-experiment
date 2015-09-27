Wizard = require './Wizard'
{ b0, b1 } = require('./BranchingWizardStepA').actionCreators

actions = {'FOR_ME', 'FOR_SOMEONE_ELSE'}

actionCreators =
  forMe: () ->
    (dispatch) ->
      dispatch {type: actions.FOR_ME}
      dispatch Wizard.actionCreators.advance b0()
  forSomeoneElse: () ->
    (dispatch) ->
      dispatch {type: actions.FOR_SOMEONE_ELSE}
      dispatch Wizard.actionCreators.advance b1()

reducer = (state = null, action) ->
  switch action.type
    when actions.FOR_ME then actions.FOR_ME
    when actions.FOR_SOMEONE_ELSE then actions.FOR_SOMEONE_ELSE
    else state

module.exports = {actions, actionCreators, reducer}


# cheeky little unit tests

{ createStore, applyMiddleware, combineReducers } = require 'redux'
thunk = require('redux-thunk')

createStoreWithMiddleware = applyMiddleware(thunk)(createStore)
store = createStoreWithMiddleware combineReducers {forWho: reducer, wizard: Wizard.reducer}
store2 = createStoreWithMiddleware combineReducers {forWho: reducer, wizard: Wizard.reducer}


console.assert store.getState().forWho is null, 'initial null'
store.dispatch actionCreators.forMe()
console.assert store.getState().forWho is 'FOR_ME', 'can set for me'
console.assert store.getState().wizard is 'B0', 'forMe magically jumps to wizard B0 state'

store2.dispatch actionCreators.forSomeoneElse()
console.assert store2.getState().forWho is 'FOR_SOMEONE_ELSE', 'can set forSomeoneElse'
console.assert store2.getState().wizard is 'B1', 'forSomeoneElse magically jumps to wizard B1 state'

