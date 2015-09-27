


actions = {'ADVANCE_B0', 'ADVANCE_B1'}

actionCreators =
  b0: () -> {type: actions.ADVANCE_B0}
  b1: () -> {type: actions.ADVANCE_B1}

reducer = (state = null, action) ->
  switch action.type
    when actions.ADVANCE_B0 then 'B0'
    when actions.ADVANCE_B1 then 'B1'
    else state

module.exports = {actions, actionCreators, reducer}
