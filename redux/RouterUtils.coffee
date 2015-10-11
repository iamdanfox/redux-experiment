ThunkForwarder = require './ThunkForwarder'


routerUtils = ({prefix, unprefix}) ->

  wrapAction = (action) -> Object.assign {}, action, {type: prefix action.type}
  wrapState = (inner) -> {inner}
  unwrapState = ({inner}) -> inner

  makeActionCreators = (handlePath) ->
    wrap: ThunkForwarder({wrapAction, unwrapState})
    handlePath: handlePath

  makeReducer = (initialState, innerReducer, pathFromState) ->
    unwrapAction = (action) -> if (type = unprefix action.type)? then Object.assign {}, action, {type} else null

    return (state = initialState, action) ->
      innerState = innerReducer unwrapState(state), unwrapAction(action) or {}
      newUrl = pathFromState innerState
      pathChanged = newUrl isnt state.url
      return Object.assign wrapState(innerState), {url: newUrl, pathChanged}

  return {wrapAction, wrapState, unwrapState, makeActionCreators, makeReducer}

module.exports = routerUtils
