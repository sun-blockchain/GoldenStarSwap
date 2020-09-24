import { Layout } from 'antd';
import React from 'react';
import SwapPair from 'components/SwapPair';
import WalletPair from 'components/WalletPair';

const { Content } = Layout;

function MainSwap() {
  return (
    <Layout>
      <Content>
        <SwapPair></SwapPair>
        <WalletPair></WalletPair>
      </Content>
    </Layout>
  );
}

export default MainSwap;
