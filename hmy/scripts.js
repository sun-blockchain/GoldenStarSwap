require('dotenv').config();
const { Harmony } = require('@harmony-js/core');
const { ChainID, ChainType } = require('@harmony-js/utils');

const hmy = new Harmony(process.env.TESTNET_0_URL, {
  chainType: ChainType.Harmony,
  chainId: ChainID.HmyTestnet
});

const GAS_LIMIT = 6721900;
const GAS_PRICE = 1000000000;

const options = {
  gasLimit: GAS_LIMIT,
  gasPrice: GAS_PRICE
};

const HmyBridge = require('./build/contracts/HmyBridge.json');
const hmyBridgeAddress = HmyBridge.networks['2'].address;

exports.unlockOne = async function (price, receiver, receiptId) {
  try {
    const hmyBridgeContract = hmy.contracts.createContract(HmyBridge.abi, hmyBridgeAddress);
    hmyBridgeContract.wallet.addByPrivateKey(process.env.HMY_OPERATOR_PRIVATE_KEY);

    const unlockTx = hmy.transactions.newTx({
      to: hmyBridgeAddress
    });

    await hmyBridgeContract.wallet.signTransaction(unlockTx);
    await hmyBridgeContract.methods.unlockOne(price, receiver, receiptId).send(options);
    return;
  } catch (err) {
    throw err;
  }
};
