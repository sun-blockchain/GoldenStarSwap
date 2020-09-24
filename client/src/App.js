import React from 'react';
import './App.css';
import { Layout } from 'antd';
import MainSwap from 'pages/MainSwap';
const { Header, Footer } = Layout;
function App() {
  return (
    <Layout>
      <Header></Header>
      <MainSwap></MainSwap>
      <Footer></Footer>
    </Layout>
  );
}

export default App;
