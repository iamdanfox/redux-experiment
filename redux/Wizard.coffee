stepA = require './BranchingWizardStepA'


actions = {'ADVANCE'}

actionCreators =
  advance: (branchAction) -> {type: actions.ADVANCE, branchAction}

reducer = (state = 'A', action) ->
  if action.type isnt actions.ADVANCE
    return state

  switch state
    when 'A' then stepA.reducer null, action.branchAction
    when 'B0' then 'C'
    when 'B1' then 'C'
    when 'C' then 'DONE'

module.exports = {actions, actionCreators, reducer}



# cheeky little unit tests

{ createStore } = require 'redux'
store = createStore reducer
console.assert store.getState() is 'A', 'initial state A'
store.dispatch actionCreators.advance stepA.actionCreators.b1()
console.assert store.getState() is 'B1', 'can advance from A to B1'
store.dispatch actionCreators.advance()
store.dispatch actionCreators.advance()
console.assert store.getState() is 'DONE', 'advance proceeds nicely'
