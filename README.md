# Lending Vault Simulation

## Business Logic Summary
This project simulates a basic lending vault mechanism using USDT. The contract mints an initial yield buffer (100,000 USDT) and accepts ETH as a buffer. It does not execute real strategies — all funds are held as-is, simulating returns only.


## How to Run Locally
1. Clone the repo
2. Install dependencies : `npm install`
3. Compile contracts:  `npx hardhat compile`

## Contract Addresses & ABI
1. USDT Token(Mock ERC20 for testing) : `0x3f2b1C57ab1094F8c157C3a2551C7D710766C7Bb`
2. SimpleVault(Vault logic) : `0x9E899bB779155C592eF986EAB1A95996Bc316D85`
3. StrategyVault(deposit and withdraw logic) : `0x10f097D2a504eFFcE6683E891E109c6d647b2192`

`ABI files are located in the artifacts/ directory after compilation.`

## Time Spent 
Total time: ~1.5 hours
1. Contract Logic : 1 hour
2. Explanation and Setup : 30 min