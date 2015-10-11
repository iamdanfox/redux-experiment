TwoRoutableCounters = require './TwoRoutableCounters'
RoutableCounter = require './RoutableCounter'
ThunkForwarder = require './ThunkForwarder'
{ prefix, unprefix } = require('./Prefixer')('R2$')

wrapAction = (action) -> Object.assign {}, action, {type: prefix action.type}
unwrapAction = (action) -> if (type = unprefix action.type)? then Object.assign {}, action, {type} else null
wrapState = (inner) -> {inner}
unwrapState = ({inner}) -> inner

actionCreators =
  forwardAction: (actionCreatorResult) ->
    ThunkForwarder(
      wrapAction: wrapAction
      unwrapState: unwrapState
    )(actionCreatorResult)

  handlePath: (path) ->
    {left, right} = TwoRoutableCounters.actionCreators
    {handlePath} = RoutableCounter.actionCreators
    return (dispatch, getState) ->
      [leftPath, rightPath] = path.split /\//
      dispatch actionCreators.forwardAction left(handlePath leftPath), true
      dispatch actionCreators.forwardAction right(handlePath rightPath), true
      return

pathFromState = (innerState) ->
  l = TwoRoutableCounters.unwrapState(TwoRoutableCounters.sides.left, innerState)
  r = TwoRoutableCounters.unwrapState(TwoRoutableCounters.sides.right, innerState)
  return "#{l.url}/#{r.url}"

initialState = do ->
  innerInitialState = TwoRoutableCounters.reducer undefined, {}
  return Object.assign {}, wrapState(innerInitialState), {url: pathFromState innerInitialState}

reducer = (state = initialState, action) ->
  innerState = TwoRoutableCounters.reducer unwrapState(state), unwrapAction(action) or {}
  newUrl = pathFromState innerState
  pathChanged = newUrl isnt state.url
  return Object.assign wrapState(innerState), {url: newUrl, pathChanged}

module.exports = {actionCreators, reducer, unwrapState}


# cheeky little unit tests
StoreEnhancer = require './StoreEnhancer'
{ createStore, applyMiddleware } = require 'redux'
thunk = require 'redux-thunk'
# logger = require 'redux-logger'
createStoreWithMiddleware = applyMiddleware(thunk)(createStore)
triple = StoreEnhancer reducer
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
store.dispatch triple.actionCreators.historyEntry actionCreators.forwardAction left require('./RoutableCounter').actionCreators.forwardAction increment()
console.assert unwrapState(triple.unwrapState(store.getState())).left.inner is 2, 'left should have updated'
console.assert store.getState().fromBackButton is false, 'a movement forwards adds to history'
