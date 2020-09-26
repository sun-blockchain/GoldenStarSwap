import React from 'react';
// import { Button, Input, Col, Row, Divider } from 'antd';
import { Button } from 'antd';
import { useSelector } from 'react-redux';
// import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
// import { faExchangeAlt } from '@fortawesome/fontawesome-free-solid';
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
      {/* <Divider orientation='right'>Receiver Address:</Divider> */}
      {/* <Row>
        <Col span={8} offset={14}>
          <Input
            className='receiver-address'
            size='large'
            disabled={true}
            value={receiverAddress}
          />
        </Col>
      </Row> */}
      <div className='button-swap'>
        <Button size='large' shape='round' className='btn-swap' disabled={disabledBtn}>
          <label className='swap-label'>Swap</label>{' '}
          {/* <FontAwesomeIcon className='swap-icon' icon={faExchangeAlt} /> */}
        </Button>
      </div>
    </div>
  );
}

export default ReceiverSwap;
