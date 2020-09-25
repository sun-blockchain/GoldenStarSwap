const HmyFunction = require('./hmy/scripts');
const EthFunction = require('./eth/scripts');

let Web3 = require('web3');
let web3 = new Web3('https://ropsten.infura.io/v3/' + process.env.INFURA_PROJECT_ID);

exports.transferERC20toONE = async function (
  ethUserPrivateKey, // eth sender
  hmyUserAddress, // hmy receiver
  erc20TokenAddress, // ERC20 Token contract Address
  amount
) {
  try {
    let ethUserAccount = web3.eth.accounts.privateKeyToAccount(ethUserPrivateKey);
    web3.eth.accounts.wallet.add(ethUserAccount);
    web3.eth.defaultAccount = ethUserAccount.address;

    await EthFunction.checkERC20TokenBalance(erc20TokenAddress, ethUserAccount.address, amount);
    await EthFunction.approveEthManger(ethUserPrivateKey, erc20TokenAddress, amount);

    let lockedEvent = await EthFunction.lockERC20TokenFor(
      erc20TokenAddress,
      ethUserAccount.address,
      amount,
      hmyUserAddress
    );

    console.log(lockedEvent);

    await EthFunction.checkBlock(lockedEvent.blockNumber);

    await HmyFunction.unlockOne(price, hmyUserAddress, lockedEvent.transactionHash);

    process.exit(0);
  } catch (err) {
    console.log(err);
    process.exit(1);
  }
};
