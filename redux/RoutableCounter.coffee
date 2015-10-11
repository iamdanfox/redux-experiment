Counter = require './Counter'
ThunkForwarder = require './ThunkForwarder'
{ prefix, unprefix } = require('./Prefixer')('R1$')

wrapAction = (action) -> Object.assign {}, action, {type: prefix action.type}
unwrapAction = (action) -> if (type = unprefix action.type)? then Object.assign {}, action, {type} else null
wrapState = (inner) -> {inner}
unwrapState = ({inner}) -> inner

actionCreators =
  forwardAction: (actionCreatorResult) ->
    ThunkForwarder(
      wrapAction: wrapAction
      forwardGetState: unwrapState
    )(actionCreatorResult)

  handlePath: (path) ->
    if path is '' # initial load
      initial = Counter.reducer undefined, {}
      return actionCreators.forwardAction Counter.actionCreators.set(initial)

    number = parseInt path, 10
    if isNaN(number) then number = Counter.reducer undefined, {}
    return actionCreators.forwardAction Counter.actionCreators.set(number)


initialState = Object.assign wrapState(Counter.reducer undefined, {}), {url: undefined, fromBackButton: false, pathChanged: false}

reducer = (state = initialState, action) ->
  innerState = Counter.reducer unwrapState(state), unwrapAction(action) or {}
  newUrl = innerState.toString()
  pathChanged = newUrl isnt state.url
  return Object.assign wrapState(innerState), {url: newUrl, pathChanged}


module.exports = {actionCreators, reducer, unwrapState}




# cheeky little unit tests

{ createStore } = require 'redux'
store = createStore reducer
console.assert unwrapState(store.getState()) is 0, 'initial state'
console.assert store.getState().url is '0', 'initial url '
console.assert store.getState().pathChanged is true, 'path did change initially'

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
