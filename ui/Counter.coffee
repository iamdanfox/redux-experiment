React = require 'react'
{ increment, decrement, setTo7, incrementIfOdd, incrementAsync } = require('../redux/Counter').actionCreators


Counter = React.createClass
  displayName: 'Counter'

  propTypes:
    reduxState: React.PropTypes.number.isRequired
    dispatch: React.PropTypes.func.isRequired

  render: () ->
    <p>
      Clicked: {@props.reduxState} times
      {' '}
      <button onClick={() => @props.dispatch increment()}>+</button>
      {' '}
      <button onClick={() => @props.dispatch decrement()}>-</button>
      {' '}
      <button onClick={() => @props.dispatch incrementIfOdd()}>Increment if odd</button>
      {' '}
      <button onClick={() => @props.dispatch incrementAsync()}>Increment async</button>

      <button onClick={() => @props.dispatch setTo7()}>Set to 7</button>
    </p>


module.exports = Counter
