TwoRoutableCounters = require './TwoRoutableCounters'
RoutableCounter = require './RoutableCounter'
ThunkForwarder = require './ThunkForwarder'
{ prefix, unprefix } = require('./Prefixer')('Rt$')

extendAction = (extension, action) ->
  prefixedExtension = {}
  for key,val of extension
    prefixedExtension[prefix key] = val
  return Object.assign {}, action, prefixedExtension
unextendAction = (extensionKeyObject, originalAction) ->
  action = Object.assign {}, originalAction
  extension = {}
  for key,val of extensionKeyObject
    extension[key] = action[prefix key]
  delete action[prefix key]
  return {action, extension}

wrapAction = (action) -> Object.assign {}, action, {type: prefix action.type}
unwrapAction = (action) ->
  return null unless (type = unprefix action.type)?
  return Object.assign {}, action, {type}

wrapState = (inner) -> {inner}
unwrapState = ({inner}) -> inner



actionCreators =
  forwardAction: (actionCreatorResult, fromBackButton = false) ->
    ThunkForwarder(
      forwardPlain: (action) -> extendAction {fromBackButton}, wrapAction action
      forwardDispatch: (realDispatch) -> (a) -> realDispatch extendAction {fromBackButton}, wrapAction a
      forwardGetState: (realGetState) -> () -> unwrapState realGetState()
    )(actionCreatorResult)

  handlePath: (path, fromBackButton = false) ->
    {left, right} = TwoRoutableCounters.actionCreators
    {handlePath} = RoutableCounter.actionCreators
    return (dispatch, getState) ->
      [leftPath, rightPath] = path.split /\//
      dispatch actionCreators.forwardAction left(handlePath leftPath), fromBackButton
      dispatch actionCreators.forwardAction right(handlePath rightPath), fromBackButton
      return

  backToPath: (path) ->
    actionCreators.handlePath path, false


lrRoutables = (innerState) ->
  leftRoutable = TwoRoutableCounters.unwrapState(TwoRoutableCounters.sides.left, innerState)
  rightRoutable = TwoRoutableCounters.unwrapState(TwoRoutableCounters.sides.right, innerState)
  return {leftRoutable, rightRoutable}

pathFromRoutables = ({leftRoutable, rightRoutable}) -> "#{leftRoutable.url}/#{rightRoutable.url}"
backButtonFromRoutables = ({leftRoutable, rightRoutable}) ->
  return false if leftRoutable.fromBackButton is false
  return false if rightRoutable.fromBackButton is false
  return true

initialState = do ->
  innerInitialState = TwoRoutableCounters.reducer undefined, {}
  routables = lrRoutables innerInitialState
  return Object.assign {}, wrapState(innerInitialState), {
    url: pathFromRoutables routables,
    fromBackButton: backButtonFromRoutables routables
  }

reducer = (state = initialState, action) ->
  actionAndExtension = unextendAction {'fromBackButton'}, unwrapAction(action) or {}
  innerState = TwoRoutableCounters.reducer unwrapState(state), actionAndExtension.action
  routables = lrRoutables innerState
  newUrl = pathFromRoutables routables
  pathChanged = newUrl isnt state.url
  # console.log action.type, newUrl, routables, backButtonFromRoutables routables
  # if backButtonFromRoutables(routables) is false # actions can prevent history entries
  #   fromBackButton = false
  return Object.assign wrapState(innerState), {url: newUrl, pathChanged}


module.exports = {actionCreators, reducer, unwrapState}

# cheeky little unit tests
{ createStore, applyMiddleware } = require 'redux'
thunk = require 'redux-thunk'
createStoreWithMiddleware = applyMiddleware(thunk)(createStore)
store = createStoreWithMiddleware reducer

# console.assert store.getState().url is '0/0', 'initial path'
# console.assert store.getState().fromBackButton is false, 'no history entries initially!'

# store.dispatch actionCreators.handlePath '1/0'
# console.assert unwrapState(store.getState()).left.inner is 1, 'left should have updated'
# console.assert unwrapState(store.getState()).right.inner is 0, 'right should have stayed at zero'
# console.log store.getState()
# console.assert store.getState().fromBackButton, 'should update history'

# store.dispatch actionCreators.handlePath '0/1'
# console.assert unwrapState(store.getState()).left.inner is 0, 'left should have stayed zero'
# console.assert unwrapState(store.getState()).right.inner is 1, 'right should have updated to 1'
# console.assert store.getState().fromBackButton, 'should update history'
#
# store.dispatch actionCreators.backToPath '1/0'
# console.log actionCreators.backToPath('1/0') (a) -> console.log a
# console.log store.getState()
# console.assert unwrapState(store.getState()).left.inner is 1, 'left should have updated'
# console.assert unwrapState(store.getState()).right.inner is 0, 'right should have stayed at zero'
# console.assert unwrapState(store.getState()).fromBackButton is false, 'should not create history entry for a back action'


# console.assert unwrapState(store.getState()) is 1, 'state has changed after handlePath'
# console.assert store.getState().url is '1', 'url has changed'
# console.assert store.getState().fromBackButton is true, 'should create history entries by default'
#
#
# console.assert unwrapState(store.getState()) is 0, 'state has changed after backToPath'
# console.assert store.getState().url is '0', 'url has changed'
#
# store.dispatch {type:'UNKNOWN'}
#
# console.assert store.getState().fromBackButton is false, 'unchanged url shouldnt create history'
