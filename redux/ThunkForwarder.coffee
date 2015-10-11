{ compose } = require 'redux'


thunkForwarder = ({wrapAction, unwrapState}) ->
  (actionCreatorResult) ->
    if typeof actionCreatorResult is 'function' # ie, redux-thunk
      return (dispatch, getState) -> actionCreatorResult compose(dispatch, wrapAction), compose(unwrapState, getState)
    else
      return wrapAction actionCreatorResult

module.exports = thunkForwarder
