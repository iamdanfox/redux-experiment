{ compose } = require 'redux'


thunkForwarder = ({wrapAction, forwardGetState}) ->
  (actionCreatorResult) ->
    if typeof actionCreatorResult is 'function' # ie, redux-thunk
      return (dispatch, getState) -> actionCreatorResult ((a) -> dispatch wrapAction a), compose(forwardGetState, getState)
    else
      return wrapAction actionCreatorResult

# slimmedDownThunkForwarder = ({wrapAction, unwrapState}) ->
#   (a) ->
#     if typeof actionCreatorResult is 'function' # ie, redux-thunk
#       return (dispatch, getState) -> actionCreatorResult dispatch(wrapAction a), unwrapState(getState())
#     else
#       return wrapAction a

module.exports = thunkForwarder
