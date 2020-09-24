export const SET_SENDER = 'SET_SENDER';
export const setSender = address => dispatch => {
  dispatch({
    type: SET_SENDER,
    address
  });
};

export const SET_RECEIVER = 'SET_RECEIVER';
export const setReceiver = address => dispatch => {
  dispatch({ type: SET_RECEIVER, address });
};

export const SET_WEB3 = 'SET_WEB3';
export const setWeb3 = web3 => dispatch => {
  dispatch({ type: SET_WEB3, web3 });
};
