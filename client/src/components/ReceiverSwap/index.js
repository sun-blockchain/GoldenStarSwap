import React, { useState } from 'react';
import { Button, Input, Col, Row, Divider, Modal } from 'antd';
import { useSelector } from 'react-redux';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faExchangeAlt } from '@fortawesome/fontawesome-free-solid';
import { approve } from 'utils/erc20.js';
import './index.css';
function ReceiverSwap() {
  const receiverAddress = useSelector(state => state.receiverAddress);
  const senderAddress = useSelector(state => state.senderAddress);
  const sendAmout = useSelector(state => state.sendAmout);
  const senderToken = useSelector(state => state.senderToken);
  let disabledBtn = !(senderAddress && receiverAddress);

  const [loading, setLoading] = useState(false);
  const [visible, setVisible] = useState(false);

  const approveErc20 = async () => {
    setLoading(true);
    await approve(senderToken, senderAddress, sendAmout * 10 ** 18);
    setLoading(false);
  };

  return (
    <div className='receiver-swap'>
      <Divider orientation='left'>Receiver Address:</Divider>
      <Row>
        <Col span={6} offset={1}>
          <Input
            className='receiver-address'
            size='large'
            disabled={true}
            value={receiverAddress}
          />
        </Col>
        <Col span={6} offset={6}>
          <Button
            size='large'
            shape='round'
            className='btn-swap'
            disabled={disabledBtn}
            onClick={() => setVisible(true)}
          >
            <label className='swap-label'>Swap</label>{' '}
            <FontAwesomeIcon className='swap-icon' icon={faExchangeAlt} />
          </Button>
        </Col>
      </Row>
      <Modal
        visible={visible}
        title='Swap'
        // onOk={this.handleOk}
        onCancel={() => setVisible(false)}
        footer={[
          <Button key='Approve' type='primary' loading={loading} onClick={() => approveErc20()}>
            Approve
          </Button>,
          <Button key='Transfer' type='primary' disabled={true} onClick={() => {}}>
            Transfer
          </Button>
        ]}
      >
        <p>Some contents...</p>
      </Modal>
    </div>
  );
}

export default ReceiverSwap;
