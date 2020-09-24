import React from 'react';
import { Button } from 'antd';
import { connectMetamask } from 'utils/connectMetaMask';
function MetaMask({ isSender }) {
  return (
    <Button type='dashed' size='large' onClick={() => connectMetamask(isSender)}>
      Metamask
    </Button>
  );
}

export default MetaMask;
