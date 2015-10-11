React = require 'react'

ReduxNest = ({inner, unwrapState, wrap}) ->

  unless inner? and (typeof unwrapState is 'function') and (typeof wrap is 'function')
    throw "ReduxNest requires inner, unwrapState and wrap parameters"

  return React.createClass
    displayName: 'ReduxNest'

    propTypes:
      reduxState: React.PropTypes.object.isRequired
      dispatch: React.PropTypes.func.isRequired

    render: () ->
      props =
        reduxState: unwrapState @props.reduxState
        dispatch: (action) => @props.dispatch wrap action

      Inner = inner
      <Inner {...props} />


module.exports = ReduxNest
