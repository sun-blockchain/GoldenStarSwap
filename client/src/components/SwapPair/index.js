import React from 'react';
import { Select, Button, Input, Col, Row, InputNumber, Divider } from 'antd';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faExchangeAlt } from '@fortawesome/fontawesome-free-solid';
import './index.css';
const { Option } = Select;

function SwapPair() {
  return (
    <div className='swap-pair'>
      <Divider orientation='left'></Divider>
      <Input.Group size='large'>
        <Row gutter={16}>
          <Col xs={2} sm={4} md={6} lg={8} xl={10}>
            <Divider orientation='left'>Have</Divider>
            <Row gutter={[8, 8]}>
              <Col span={12}>
                <Select defaultValue='eth' style={{ width: 120 }}>
                  <Option value='eth'>Ethereum</Option>
                  <Option value='one'>One</Option>
                </Select>
              </Col>
              <Col span={12}>
                <InputNumber
                  style={{
                    width: 250,
                    textAlign: 'center'
                  }}
                ></InputNumber>
              </Col>
            </Row>
          </Col>

          <Col xs={20} sm={16} md={12} lg={8} xl={4}>
            <Button>
              <FontAwesomeIcon icon={faExchangeAlt} />
            </Button>
          </Col>

          <Col xs={2} sm={4} md={6} lg={8} xl={10}>
            <Divider orientation='left'>Want</Divider>
            <Row gutter={[8, 8]}>
              <Col span={12}>
                <Select defaultValue='one' style={{ width: 120 }}>
                  <Option value='eth'>Ethereum</Option>
                  <Option value='one'>One</Option>
                </Select>
              </Col>
              <Col span={12}>
                <InputNumber
                  style={{
                    width: 250,
                    textAlign: 'center'
                  }}
                ></InputNumber>
              </Col>
            </Row>
          </Col>
        </Row>
      </Input.Group>
    </div>
  );
}

export default SwapPair;
