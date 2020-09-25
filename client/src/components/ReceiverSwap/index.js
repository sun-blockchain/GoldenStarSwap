import React from 'react';
import { Button, Input, Col, Row, Divider } from 'antd';
import { useSelector } from 'react-redux';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faExchangeAlt } from '@fortawesome/fontawesome-free-solid';
import './index.css';
function ReceiverSwap() {
  const receiverAddress = useSelector(state => state.receiverAddress);
  const senderAddress = useSelector(state => state.senderAddress);
  let disabledBtn = !(senderAddress && receiverAddress);
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
          <Button size='large' shape='round' className='btn-swap' disabled={disabledBtn}>
            <label className='swap-label'>Swap</label>{' '}
            <FontAwesomeIcon className='swap-icon' icon={faExchangeAlt} />
          </Button>
        </Col>
      </Row>
    </div>
  );
}

export default ReceiverSwap;
