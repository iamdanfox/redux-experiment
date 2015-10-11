React = require 'react'

ReduxNest = ({inner, unwrapState, forwardAction}) ->

  unless inner? and (typeof unwrapState is 'function') and (typeof forwardAction is 'function')
    throw "ReduxNest requires inner, unwrapState and forwardAction parameters"

  return React.createClass
    displayName: 'ReduxNest'

    propTypes:
      reduxState: React.PropTypes.object.isRequired
      dispatch: React.PropTypes.func.isRequired

    render: () ->
      props =
        reduxState: unwrapState @props.reduxState
        dispatch: (action) => @props.dispatch forwardAction action

      Inner = inner
      <Inner {...props} />


module.exports = ReduxNest
