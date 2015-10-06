Counter = require './Counter'


actions = { 'WRAPPED' }

actionCreators =
  wrapped: (wrappedAction) ->
    return {type: actions.WRAPPED, wrappedAction}

  handleUrl: (newUrl) ->
    actionCreators.wrapped Counter.actionCreators.set parseInt(newUrl, 10)

reducer = (state = {wrappedState: undefined, url: undefined}, action) ->
  wrappedState = Counter.reducer state.wrappedState, action.wrappedAction or {}
  return { wrappedState, url: wrappedState.toString() }


module.exports = {actions, actionCreators, reducer}

# cheeky little unit tests

{ createStore } = require 'redux'
store = createStore reducer
console.assert store.getState().wrappedState is 0, 'initial state'
console.assert store.getState().url is '0', 'initial url '

store.dispatch actionCreators.handleUrl '1'

console.assert store.getState().wrappedState is 1, 'state has changed after handleUrl'
console.assert store.getState().url is '1', 'url has changed'