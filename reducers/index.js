import { combineReducers } from 'redux';

import { INCREMENT_COUNTER, DECREMENT_COUNTER, SET_TO_7 } from '../actions/counter';

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

export default rootReducer;
