import React from 'react';
import { Row, Col } from 'antd';
import { useSelector } from 'react-redux';
import MetaMaskWallet from 'components/MetaMaskWallet';
import MathWallet from 'components/MathWallet';
import LogoutButton from 'components/LogoutButton';
import './index.css';

function WalletPair() {
  const senderAddress = useSelector(state => state.senderAddress);
  const receiverAddress = useSelector(state => state.receiverAddress);

  let sender;
  senderAddress
    ? (sender = (
        <div>
          {senderAddress} <LogoutButton isSender={true} />
        </div>
      ))
    : (sender = <MetaMaskWallet isSender={true}></MetaMaskWallet>);

  let receiver;
  receiverAddress
    ? (receiver = (
        <div>
          {receiverAddress} <LogoutButton isSender={false} />
        </div>
      ))
    : (receiver = <MathWallet isSender={false}></MathWallet>);

  return (
    <div className='wallet-pair'>
      <Row gutter={[8, 8]}>
        <Col span={8} className='wallet-left'>
          <div>Ethereum</div>
          {sender}
        </Col>

        <Col span={8} offset={7} className='wallet-right'>
          <div>Harmony</div>
          {receiver}
        </Col>
      </Row>
    </div>
  );
}

export default WalletPair;
