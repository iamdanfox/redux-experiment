var React = require('react');
var { Provider, connect } = require('react-redux');
var { createStore, applyMiddleware, combineReducers, bindActionCreators } = require('redux');
var thunk = require('redux-thunk');

var dummy = require('./dummy.coffee');

// ACTIONS

var INCREMENT_COUNTER = 'INCREMENT_COUNTER';
var DECREMENT_COUNTER = 'DECREMENT_COUNTER';
var SET_TO_7 = 'SET_TO_7';

// ACTION CREATORS

function increment() {
  return {
    type: INCREMENT_COUNTER
  };
}

function decrement() {
  return {
    type: DECREMENT_COUNTER
  };
}

function incrementIfOdd() {
  return (dispatch, getState) => {
    var { counter } = getState();

    if (counter % 2 === 0) {
      return;
    }

    dispatch(increment());
  };
}

function incrementAsync(delay = 1000) {
  return dispatch => {
    setTimeout(() => {
      dispatch(increment());
    }, delay);
  };
}


function setTo7() {
  return {
    type: SET_TO_7
  };
}

// UI

var Counter = React.createClass({
  propTypes: {
    increment: React.PropTypes.func.isRequired,
    incrementIfOdd: React.PropTypes.func.isRequired,
    incrementAsync: React.PropTypes.func.isRequired,
    decrement: React.PropTypes.func.isRequired,
    setTo7: React.PropTypes.func.isRequired,
    counter: React.PropTypes.number.isRequired
  },

  render: function() {
    var { increment, incrementIfOdd, incrementAsync, decrement, setTo7, counter } = this.props;
    return (
      <p>
        Clicked: {counter} times
        {' '}
        <button onClick={increment}>+</button>
        {' '}
        <button onClick={decrement}>-</button>
        {' '}
        <button onClick={incrementIfOdd}>Increment if odd</button>
        {' '}
        <button onClick={() => incrementAsync()}>Increment async</button>

        <button onClick={setTo7}>Set to 7</button>
      </p>
    );
  }
});

function mapStateToProps(state) {
  return {
    counter: state.counter
  };
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators({ increment, decrement, incrementAsync, incrementIfOdd, setTo7 }, dispatch);
}

var App = connect(mapStateToProps, mapDispatchToProps)(Counter);

// REDUCERS

function counter(state = 0, action) {
  switch (action.type) {
  case INCREMENT_COUNTER:
    return state + 1;
  case DECREMENT_COUNTER:
    return state - 1;
  case SET_TO_7:
    return 7;
  default:
    return state;
  }
}

var rootReducer = combineReducers({
  counter
});


var createStoreWithMiddleware = applyMiddleware(
  thunk
)(createStore);

var store = createStoreWithMiddleware(rootReducer);

// INITIALISATION

React.render(
  <Provider store={store}>
    {() => <App />}
  </Provider>,
  document.getElementById('root')
);
