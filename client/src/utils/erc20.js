import ERC20 from 'contracts/IERC20.json';
import Web3 from 'web3';
export const balanceOf = async (tokenAddress, walletAddress) => {
  const web3 = new Web3(window.ethereum);
  const erc20 = new web3.eth.Contract(ERC20.abi, tokenAddress);
  const balance = await erc20.methods.balanceOf(walletAddress).call();
  return balance;
};

export const approve = async (tokenAddress, walletAddress, amount) => {
  const web3 = new Web3(window.ethereum);
  const erc20 = new web3.eth.Contract(ERC20.abi, tokenAddress);
  await erc20.methods
    .approve(
      '0xf73eab542a1cec0235b8612784b6f45040492c4763a401b734345d24b22801e2'.toString(),
      amount
    )
    .send({ from: walletAddress });
};
