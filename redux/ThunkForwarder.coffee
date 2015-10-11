{ compose } = require 'redux'


thunkForwarder = ({forwardPlain, forwardGetState}) ->
  (actionCreatorResult) ->
    if typeof actionCreatorResult is 'function' # ie, redux-thunk
      return (dispatch, getState) -> actionCreatorResult ((a) -> dispatch forwardPlain a), compose(forwardGetState, getState)
    else
      return forwardPlain actionCreatorResult

# slimmedDownThunkForwarder = ({wrapAction, unwrapState}) ->
#   (a) ->
#     if typeof actionCreatorResult is 'function' # ie, redux-thunk
#       return (dispatch, getState) -> actionCreatorResult dispatch(wrapAction a), unwrapState(getState())
#     else
#       return wrapAction a

module.exports = thunkForwarder
