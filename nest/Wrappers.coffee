wrappers =
  wrapState: (inner) -> {inner}
  unwrapState: ({inner}) -> inner
  wrapAction: (prefix) -> (action) -> Object.assign {}, action, {type: prefix action.type}
  unwrapAction: (unprefix) -> (action) -> if (type = unprefix action.type)? then Object.assign {}, action, {type} else null

module.exports = wrappers
