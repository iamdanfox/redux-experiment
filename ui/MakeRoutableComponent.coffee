React = require 'react'

MakeRoutableComponent = (Inner, unwrapState, forwardAction) ->
  RoutableWrapper = React.createClass
    displayName: 'RoutableWrapper'

    propTypes:
      reduxState: React.PropTypes.object.isRequired
      dispatch: React.PropTypes.func.isRequired

    render: () ->
      props =
        reduxState: unwrapState @props.reduxState
        dispatch: (action) => @props.dispatch forwardAction action

      <Inner {...props} />


module.exports = MakeRoutableComponent
