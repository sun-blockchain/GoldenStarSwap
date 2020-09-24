import React from 'react';
import { Row, Col, Button } from 'antd';
import MetaMaskWallet from 'components/MetaMaskWallet';
import './index.css';

function WalletPair() {
  return (
    <div className='wallet-pair'>
      <Row gutter={[8, 8]}>
        <Col span={8} className='wallet-left'>
          <div>Ethereum</div>
          <MetaMaskWallet></MetaMaskWallet>
        </Col>

        <Col span={8} offset={7} className='wallet-right'>
          <div>Harmony</div>
          <Button type='dashed' size='large'>
            MathWallet
          </Button>
        </Col>
      </Row>
    </div>
  );
}

export default WalletPair;
