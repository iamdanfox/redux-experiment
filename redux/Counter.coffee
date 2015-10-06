


actions = {'INCREMENT_COUNTER', 'DECREMENT_COUNTER', 'SET_TO_7', 'SET'}

actionCreators =
  increment: () -> {type: actions.INCREMENT_COUNTER}
  decrement: () -> {type: actions.DECREMENT_COUNTER}
  setTo7: () -> {type: actions.SET_TO_7}
  incrementIfOdd: () -> (dispatch, getState) ->
    if getState().counter % 2 is 0
      return
    dispatch actionCreators.increment()
  incrementAsync: (delay = 1000) -> (dispatch) ->
    setTimeout (() ->
      dispatch actionCreators.increment()
    ), delay
  set: (counter) ->
    {type: actions.SET, counter}

reducer = (state = 0, action) ->
  switch action.type
    when actions.INCREMENT_COUNTER then state + 1
    when actions.DECREMENT_COUNTER then state - 1
    when actions.SET_TO_7 then 7
    when actions.SET then action.counter
    else state

module.exports = {actions, actionCreators, reducer}
