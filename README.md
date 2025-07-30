# Lending Vault Simulation

## Business Logic Summary
This project simulates a basic lending vault mechanism using USDT. The contract mints an initial yield buffer (100,000 USDT) and accepts ETH as a buffer. It does not execute real strategies — all funds are held as-is, simulating returns only.


## How to Run Locally
1. Clone the repo
2. Install dependencies : `npm install`
3. Compile contracts:  `npx hardhat compile`

## Contract Addresses & ABI
1. USDT Token(Mock ERC20 for testing) : 
2. SimpleVault(Vault logic) : 
3. StrategyVault(deposit and withdraw logic) : 

`ABI files are located in the artifacts/ directory after compilation.`

## Time Spent 
Total time: ~1.5 hours
1. Contract Logic : 1 hour
2. Explanation and Setup : 30 min