React = require 'react'

ReduxNest = (Inner, unwrapState, forwardAction) ->
  return React.createClass
    displayName: 'ReduxNest'

    propTypes:
      reduxState: React.PropTypes.object.isRequired
      dispatch: React.PropTypes.func.isRequired

    render: () ->
      props =
        reduxState: unwrapState @props.reduxState
        dispatch: (action) => @props.dispatch forwardAction action

      <Inner {...props} />


module.exports = ReduxNest
