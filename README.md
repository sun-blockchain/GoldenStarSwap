<h1 align="center">Welcome to GoldenStarSwap 👋</h1>
<p>
  <img src="https://img.shields.io/badge/version-1.0-blue.svg?cacheSeconds=2592000" />
</p>

## Introduction

GoldenStarSwap brings the easiest way to swap crypto across blockchains. You can swap **ERC-20s**, **ETH** to **ONE (Harmony)** and vice versa.

To ensure fairness when exchanging cryptocurrencies, GoldenStarSwap uses **Chainlink Oracle** to be able to retrieve the value of the cryptocurrencies that users want to exchange 👌.

GoldenStarSwap swaps enable two parties who in know or trust each other to trade without a trusted third party. Through smart contract escrows, the GoldenStarSwap is guaranteed to either execute successfully or refund the parties involved

GoldenStarSwap is still being built to provide exchangeable protocols between cryptocurrencies, the next stage will be able to connect to **Cosmos** and **Tomochain** platforms.

## Architecture

This prototype includes functionality to safely lock and unlock ERC-20s, and transfer corresponding representative tokens on the Harmony chain.

#### EthBridge contract

First, the smart contract is deployed to an Ethereum network. A user can then send ERC-20s to that smart contract to lock up their ERC-20s and trigger the transfer flow.

The goal of the EthBridge smart contracts is to securely implement core functionality of the system such as ERC-20s locking and event emission without endangering any user funds.

The amount of tokens will be converted to USD amount through the price of the Chainlink Oracle

#### Oracle Chainlink

Oracle Chainlink is used on both Ethereum and Harmony sides to get the corresponding value of ERC-20 and One tokens during the swap. It can be said that this is the heart to a successful transaction

#### The Relayer

The Relayer is a service which interfaces with both blockchains, allowing validators to attest on blockchain that specific events on the Ethereum blockchain have occurred. Through the Relayer service, validators witness the events and submit proofs to HmyBridge

The Relayer process:

- Listen event **Locked** from EthBridge contract
- When an event is seen, parse information associated with the Ethereum transaction
- Uses this information then validate before sending this transaction to HmyBridge.

#### HmyBridge contract

HmyBridge contract is responsible for receiving and decoding transactions involving EthBridge claims and for processing the result of a successful claim.
The process:

- A transaction with a message is received
- The message is decoded and transformed into a generic
- Get the value OneUSD from the Oracle Chainlink to be able to calculate the corresponding amount of One that the user is receiving
- Transfer One

## Architecture Diagram

![Architecture Diagram](./images/diagram.png)

## Installation

Testnet version : Ropsten + Harmony testnet

#### Deploy EthBridge contract

#### Deploy EthBridge contract

#### Setup Relayer

#### Run Frontend

```js
cd client
yarn install
yarn start
```
