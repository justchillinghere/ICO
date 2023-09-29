# Simple farming implementation

## Description

The project is a simple farming implementation using a smart contract called Farming.sol. The smart contract allows users to stake LP tokens for a specified period of time and earn rewards in ERC20 tokens.

Here are the main features of the smart contract:

- Users can deposit LP tokens into the contract by calling the deposit function. The deposit amount cannot exceed the remaining tokens available for staking.
- The contract owner can initialize the farming by calling the initialize function. This sets the total amount of LP tokens available for staking, the percentage of rewards to be distributed, the duration of each epoch, the number of epochs, and the start time of the farming.
- Once the farming is initialized and the start time is reached, users can deposit LP tokens and start earning rewards.
- After the farming period is over, users can withdraw their staked LP tokens and claim their earned rewards by calling the withdraw and claimRewards functions respectively.
- The smart contract keeps track of each user's staked amount, deposit time, and whether they have already claimed their rewards.

## Deployed contract example

You can find and test my deployed contract in goerli testnet by this address: [0x349F6E0C3Ffc59d1d454401648374F0B7C71aA42](https://goerli.etherscan.io/address/0x349F6E0C3Ffc59d1d454401648374F0B7C71aA42)

## Installation

Clone the repository using the following command:
Install the dependencies using the following command:

```
npm i
```

## Deployment

Fill in all the required environment variables(copy .env-example to .env and fill it).
Note:

- Mnemonic is 12 words phrase you can obtain while creating a new account (in Metamask for example)
- RPC_URL may be choosen here: https://chainlist.org
- ETHERSCAN may be obtained in your account profile on etherscan

Deploy contract to the chain (mumbai testnet):

```
npx hardhat run scripts/deploy.ts --network goerli (or polygon-mumbai)
```

## Tasks

Create new task(s) ans save it(them) in the folder "tasks". Add a new task name in the file "tasks/index.ts".

Running a task:

```
npx hardhat addLiquidity --token-a {TOKEN_A ADDRESS} --token-b {TOKEN_B ADDRESS} --value-a 10000000 --value-b 10000000 --network goerli
```

Note: Replace {TOKEN\_\* ADDRESS} with the address of the token.

## Verification

Verify the installation by running the following command:

```
npx hardhat verify --network goerli {CONTRACT_ADDRESS}
```

Note: Replace {CONTRACT_ADDRESS} with the address of the contract
