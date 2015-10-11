React = require 'react'

ReduxNestComponent = ({inner, unwrapState, innerAction}) ->

  unless inner? and (typeof unwrapState is 'function') and (typeof innerAction is 'function')
    throw "ReduxNestComponent requires inner, unwrapState and innerAction parameters"

  return React.createClass
    displayName: 'ReduxNestComponent'

    propTypes:
      reduxState: React.PropTypes.object.isRequired
      dispatch: React.PropTypes.func.isRequired

    render: () ->
      props =
        reduxState: unwrapState @props.reduxState
        dispatch: (action) => @props.dispatch innerAction action

      Inner = inner
      <Inner {...props} />


module.exports = ReduxNestComponent
