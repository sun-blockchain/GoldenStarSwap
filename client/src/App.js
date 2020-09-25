import React from 'react';
import './App.css';
import { Layout } from 'antd';
import MainSwap from 'pages/MainSwap';
import Logo from 'icons/logo.png';
const { Header, Footer } = Layout;
function App() {
  return (
    <Layout>
      <Header>
        <div className='logo'>
          <img src={Logo} alt='logo' width={'80px'}></img>
        </div>
      </Header>
      <MainSwap></MainSwap>
      <Footer></Footer>
    </Layout>
  );
}

export default App;
