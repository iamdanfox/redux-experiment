Counter = require './Counter'
{ prefix, unprefix } = require('./Prefixer')('R1$')
{ wrapAction, wrapState, unwrapState, makeActionCreators, makeReducer } = require('./RouterUtils')({prefix, unprefix})

actionCreators = makeActionCreators
  handlePath: (path) ->
    if path is '' # initial load
      initial = Counter.reducer undefined, {}
      return actionCreators.wrap Counter.actionCreators.set(initial)

    number = parseInt path, 10
    if isNaN(number) then number = Counter.reducer undefined, {}
    return actionCreators.wrap Counter.actionCreators.set(number)

pathFromState = (state) -> state.toString()

reducer = makeReducer Counter.reducer, pathFromState

module.exports = {actionCreators, reducer, unwrapState}




# cheeky little unit tests

{ createStore } = require 'redux'
store = createStore reducer
console.assert unwrapState(store.getState()) is 0, 'initial state'
console.assert store.getState().url is '0', 'initial url '
console.assert store.getState().pathChanged is false, 'path shouldnt change initially (dont want to add more history entries)'

store.dispatch actionCreators.handlePath 'broken'
console.assert store.getState().url is '0', 'broken url redirected to initial'

store.dispatch actionCreators.handlePath '1'

console.assert unwrapState(store.getState()) is 1, 'state has changed after handlePath'
console.assert store.getState().url is '1', 'url has changed'
console.assert store.getState().pathChanged is true, 'path changed from 0 to 1'

store.dispatch actionCreators.handlePath '0'

console.assert unwrapState(store.getState()) is 0, 'state has changed after handlePath'
console.assert store.getState().url is '0', 'url has changed'

store.dispatch actionCreators.handlePath '0'
console.assert store.getState().pathChanged is false, 'path hasnt changed'

store.dispatch {type:'UNKNOWN'}

console.assert store.getState().pathChanged is false, 'unchanged url shouldnt create history'
