TwoRoutableCounters = require './TwoRoutableCounters'
RoutableCounter = require './RoutableCounter'
{ prefix, unprefix } = require('./Prefixer')('R2$')
{ unwrapState, makeActionCreators, makeReducer } = require('./RouterUtils')({prefix, unprefix})

actionCreators = makeActionCreators
  handlePath: (path) ->
    {wrap} = actionCreators
    {left, right} = TwoRoutableCounters.actionCreators
    {handlePath} = RoutableCounter.actionCreators
    return (dispatch, getState) ->
      [leftPath, rightPath] = path.split /\//
      dispatch wrap left handlePath leftPath
      dispatch wrap right handlePath rightPath
      return

pathFromState = (innerState) ->
  l = TwoRoutableCounters.unwrapState TwoRoutableCounters.sides.left, innerState
  r = TwoRoutableCounters.unwrapState TwoRoutableCounters.sides.right, innerState
  return "#{l.url}/#{r.url}"

reducer = makeReducer(TwoRoutableCounters.reducer, pathFromState)

module.exports = {actionCreators, reducer, unwrapState}


# cheeky little unit tests
BackButtonTracker = require './BackButtonTracker'
{ createStore, applyMiddleware } = require 'redux'
thunk = require 'redux-thunk'
# logger = require 'redux-logger'
createStoreWithMiddleware = applyMiddleware(thunk)(createStore)
triple = BackButtonTracker reducer
store = createStoreWithMiddleware triple.reducer

console.assert triple.unwrapState(store.getState()).url is '0/0', 'initial path'
console.assert store.getState().fromBackButton is false, 'no history entries initially!'

store.dispatch triple.actionCreators.noHistoryEntry actionCreators.handlePath('broken')
console.assert triple.unwrapState(store.getState()).url is '0/0', 'broken url redirected to initial'
console.assert store.getState().fromBackButton, 'even though two actions were triggered, we still shouldnt add to history'

store.dispatch triple.actionCreators.noHistoryEntry actionCreators.handlePath('0/1')
console.assert unwrapState(triple.unwrapState(store.getState())).left.inner is 0, 'left should have stayed zero'
console.assert unwrapState(triple.unwrapState(store.getState())).right.inner is 1, 'right should have updated to 1'

store.dispatch triple.actionCreators.noHistoryEntry actionCreators.handlePath('1/0')
console.assert unwrapState(triple.unwrapState(store.getState())).left.inner is 1, 'left should have updated'
console.assert unwrapState(triple.unwrapState(store.getState())).right.inner is 0, 'right should have stayed at zero'

{left, right} = require('./TwoRoutableCounters').actionCreators
{increment} = require('./Counter.coffee').actionCreators
store.dispatch triple.actionCreators.historyEntry actionCreators.wrap left require('./RoutableCounter').actionCreators.wrap increment()
console.assert unwrapState(triple.unwrapState(store.getState())).left.inner is 2, 'left should have updated'
console.assert store.getState().fromBackButton is false, 'a movement forwards adds to history'
