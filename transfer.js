const HmyFunction = require('./hmy/scripts');
const EthFunction = require('./eth/scripts');

exports.transferERC20toONE = async function (
  ethUserPrivateKey, // eth sender
  hmyUserAddress, // hmy receiver
  erc20TokenAddress, // ERC20 Token contract Address
  amount
) {
  try {
    await EthFunction.checkBalanceAndApproveEthManger(ethUserPrivateKey, erc20TokenAddress, amount);

    let lockedEvent = await EthFunction.lockERC20Token(
      erc20TokenAddress,
      ethUserPrivateKey,
      amount,
      hmyUserAddress
    );

    console.log(lockedEvent);

    await EthFunction.checkBlock(lockedEvent.blockNumber);

    await HmyFunction.unlockOne(
      lockedEvent.argv.amount,
      lockedEvent.argv.price,
      hmyUserAddress,
      lockedEvent.transactionHash
    );

    process.exit(0);
  } catch (err) {
    console.log(err);
    process.exit(1);
  }
};

exports.transferETHtoONE = async function (
  ethUserPrivateKey, // eth sender
  hmyUserAddress, // hmy receiver
  amount
) {
  try {
    let lockedEvent = await EthFunction.lockETH(ethUserPrivateKey, amount, hmyUserAddress);

    console.log(lockedEvent);

    await EthFunction.checkBlock(lockedEvent.blockNumber);

    await HmyFunction.unlockOne(
      lockedEvent.argv.amount,
      lockedEvent.argv.price,
      hmyUserAddress,
      lockedEvent.transactionHash
    );

    process.exit(0);
  } catch (err) {
    console.log(err);
    process.exit(1);
  }
};
