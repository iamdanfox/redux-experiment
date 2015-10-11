thunkForwarder = ({forwardPlain, forwardDispatch, forwardGetState}) ->
  (actionCreatorResult) ->
    if typeof actionCreatorResult is 'function' # ie, redux-thunk
      return (dispatch, getState) -> actionCreatorResult forwardDispatch(dispatch), forwardGetState(getState)
    else
      return forwardPlain actionCreatorResult


module.exports = thunkForwarder
