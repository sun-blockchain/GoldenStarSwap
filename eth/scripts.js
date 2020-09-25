require('dotenv').config();

const BN = require('bn.js');

const Web3 = require('web3');
const web3 = new Web3('https://ropsten.infura.io/v3/' + process.env.INFURA_PROJECT_ID);

const ERC20 = require('./build/contracts/ERC20.json');

const EthBridge = require('./build/contracts/EthBridge.sol');
const ethBridgeAddress = EthBridge.networks['3'].address;
const ethBridgeContract = new web3.eth.Contract(EthBridge.abi, ethBridgeAddress);

const sleep = duration => new Promise(res => setTimeout(res, duration));

const AVG_BLOCK_TIME = 20 * 1000;
const BLOCK_TO_FINALITY = 10;

exports.checkERC20TokenBalance = async function (erc20TokenAddress, ethUserAddr, amount) {
  let erc20Contract = new web3.eth.Contract(ERC20.abi, erc20TokenAddress);
  let result = await erc20Contract.methods.balanceOf(ethUserAddr).call();

  if (result < amount) {
    throw new Error('Your balance not enough to transfer!');
  }
  return;
};

exports.approveEthManger = async function (ethUserPrivateKey, erc20TokenAddress, amount) {
  try {
    let ethUserAccount = web3.eth.accounts.privateKeyToAccount(ethUserPrivateKey);
    web3.eth.accounts.wallet.add(ethUserAccount);
    web3.eth.defaultAccount = ethUserAccount.address;

    let erc20Contract = new web3.eth.Contract(ERC20.abi, erc20TokenAddress);

    await erc20Contract.methods.approve(ethManagerAddress, amount).send({
      from: ethUserAccount.address,
      gas: process.env.ETH_GAS_LIMIT,
      gasPrice: new BN(await web3.eth.getGasPrice()).mul(new BN(1))
    });
    return;
  } catch (err) {
    console.log(err);
    throw err;
  }
};

exports.lockERC20TokenFor = async function (
  erc20TokenAddress,
  ethUserAddress,
  amount,
  hmyUserAddress
) {
  try {
    let ethOperatorAccount = web3.eth.accounts.privateKeyToAccount(
      process.env.OPERATOR_PRIVATE_KEY
    );
    web3.eth.accounts.wallet.add(ethOperatorAccount);
    web3.eth.defaultAccount = ethOperatorAccount.address;

    let transaction = await ethBridgeContract.methods
      .lockTokenFor(erc20TokenAddress, ethUserAddress, amount, hmyUserAddress)
      .send({
        from: ethOperatorAccount.address,
        gas: process.env.ETH_GAS_LIMIT,
        gasPrice: new BN(await web3.eth.getGasPrice()).mul(new BN(1))
      });

    return transaction.events.Locked;
  } catch (err) {
    throw err;
  }
};

exports.checkBlock = async function (blockNumber) {
  while (true) {
    let currentBlock = await web3.eth.getBlockNumber();
    if (currentBlock <= blockNumber + BLOCK_TO_FINALITY) {
      console.log(
        `Currently at block ${blockNumber}, waiting for block ${expectedBlockNumber} to be confirmed`
      );
      await sleep(AVG_BLOCK_TIME);
    } else {
      return;
    }
  }
};
