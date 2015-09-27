const React = require('react');
const { Provider, connect } = require('react-redux');
const { createStore, applyMiddleware, combineReducers, bindActionCreators } = require('redux');
const thunk = require('redux-thunk');

// ACTIONS

const INCREMENT_COUNTER = 'INCREMENT_COUNTER';
const DECREMENT_COUNTER = 'DECREMENT_COUNTER';
const SET_TO_7 = 'SET_TO_7';

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
    const { counter } = getState();

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

const Counter = React.createClass({
  propTypes: {
    increment: React.PropTypes.func.isRequired,
    incrementIfOdd: React.PropTypes.func.isRequired,
    incrementAsync: React.PropTypes.func.isRequired,
    decrement: React.PropTypes.func.isRequired,
    setTo7: React.PropTypes.func.isRequired,
    counter: React.PropTypes.number.isRequired
  },

  render: function() {
    const { increment, incrementIfOdd, incrementAsync, decrement, setTo7, counter } = this.props;
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

const App = connect(mapStateToProps, mapDispatchToProps)(Counter);

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

const rootReducer = combineReducers({
  counter
});


const createStoreWithMiddleware = applyMiddleware(
  thunk
)(createStore);

const store = createStoreWithMiddleware(rootReducer);

// INITIALISATION

React.render(
  <Provider store={store}>
    {() => <App />}
  </Provider>,
  document.getElementById('root')
);
