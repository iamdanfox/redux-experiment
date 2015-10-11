ThunkForwarder = require './ThunkForwarder'


routerUtils = ({prefix, unprefix}) ->

  wrapAction = (action) -> Object.assign {}, action, {type: prefix action.type}
  wrapState = (inner) -> {inner}
  unwrapState = ({inner}) -> inner
  unwrapAction = (action) -> if (type = unprefix action.type)? then Object.assign {}, action, {type} else null

  makeActionCreators = ({handlePath}) ->
    wrap: ThunkForwarder({wrapAction, unwrapState})
    handlePath: handlePath

  makeReducer = (innerReducer, pathFromState) ->

    initialState = do ->
      innerInitialState = innerReducer undefined, {}
      return Object.assign {}, wrapState(innerInitialState), {url: pathFromState innerInitialState}

    return (state = initialState, action) ->
      innerState = innerReducer unwrapState(state), unwrapAction(action) or {}
      return Object.assign wrapState(innerState), {url: pathFromState innerState}

  return {unwrapState, makeActionCreators, makeReducer}

module.exports = routerUtils
