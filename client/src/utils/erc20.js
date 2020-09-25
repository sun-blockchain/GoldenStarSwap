import ERC20 from 'contracts/IERC20.json';
import Web3 from 'web3';
export const balanceOf = async (tokenAddress, walletAddress) => {
  const web3 = new Web3(window.ethereum);
  const erc20 = new web3.eth.Contract(ERC20.abi, tokenAddress);
  const balance = await erc20.methods.balanceOf(walletAddress).call();
  return balance;
};
