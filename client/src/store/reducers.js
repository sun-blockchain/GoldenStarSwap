import * as actions from './actions';
const initialState = {
  web3: null,

  senderAddress: null,
  senderBalance: 0,
  senderType: '',

  receiverAddress: null,
  receiverBalance: 0,
  receiverType: ''
};
const rootReducer = (state = initialState, action) => {
  switch (action.type) {
    case actions.SET_SENDER:
      return {
        ...state,
        senderAddress: action.address
      };
    case actions.SET_RECEIVER:
      return {
        ...state,
        senderAddress: action.address
      };
    case actions.SET_WEB3:
      return {
        ...state,
        web3: action.web3
      };
    default:
      return state;
  }
};
export default rootReducer;
