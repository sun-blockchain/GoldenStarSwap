import { Layout } from 'antd';
import React from 'react';
import SwapPair from 'components/SwapPair';
import WalletPair from 'components/WalletPair';
import ReceiverSwap from 'components/ReceiverSwap';
const { Content } = Layout;

function MainSwap() {
  return (
    <Layout>
      <Content>
        <SwapPair />
        <ReceiverSwap />
        <WalletPair />
      </Content>
    </Layout>
  );
}

export default MainSwap;
