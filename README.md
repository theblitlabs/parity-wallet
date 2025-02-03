# StakeWallet Hardhat Project

This project demonstrates a Hardhat use case for a wallet system contract named **StakeWallet**.  
The contract allows participants (runners, solvers, creators, etc.) to:

- **Add Funds:** Deposit tokens into a wallet identified by a device ID along with a designated withdrawal address.
- **Transfer Payment:** Distribute funds from a creator's wallet (by device ID) to a solver's wallet.
- **Withdraw Funds:** Withdraw tokens from a wallet to an external address (e.g., a MetaMask wallet).
- **Update Wallet Address:** Change the withdrawal address for a wallet.
- **Recover Tokens:** Allow the contract owner to recover tokens accidentally sent to the contract.

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/your_username/your_repo.git
cd your_repo
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Environment Variables

Create a `.env` file in the project root with the following variables. **Remember to add `.env` to your `.gitignore` to keep your sensitive information private.**

```bash
SEPOLIA_RPC=https://ethereum-sepolia-rpc.publicnode.com
PRIVATE_KEY=your_private_key_here
TOKEN_ADDRESS=0xYourTokenAddressHere
```

### 4. Compile the Contracts

```bash
npx hardhat compile
```

### 5. Deploy the Contract

Deploy the **StakeWallet** contract using the deploy script:

```bash
npx hardhat run scripts/deploy.ts --network sepolia
```

### 6. Verify Contracts on Etherscan

If you have set up your Etherscan API key in Hardhat, you can verify the deployed contract:

```bash
npx hardhat verify --network sepolia <contract-address>
```

### 7. Interacting with the Contract

Here's a summary of the main functions and how to use them via scripts or the Hardhat console:

- **Add Funds:**  
  Deposit tokens into your wallet by specifying the amount, your device ID, and the withdrawal address.  
  Example:

  ```javascript
  // Using ethers.js in a script
  await stakeWallet.addFunds(amount, "device123", "0xYourWithdrawalAddress");
  ```

- **Transfer Payment:**  
  Transfer funds from a creator's wallet to a solver's wallet by providing their respective device IDs and the payment amount.  
  Example:

  ```javascript
  await stakeWallet.transferPayment(
    "creatorDevice",
    "solverDevice",
    paymentAmount
  );
  ```

- **Withdraw Funds:**  
  Withdraw funds from your wallet to your designated withdrawal address:

  ```javascript
  await stakeWallet.withdrawFunds("device123", withdrawAmount);
  ```

- **Update Wallet Address:**  
  Update the withdrawal address for an existing wallet:

  ```javascript
  await stakeWallet.updateWalletAddress("device123", "0xNewWalletAddress");
  ```

- **Get Wallet Info & Balance:**  
  Retrieve wallet details or check the balance using:

  ```javascript
  const info = await stakeWallet.getWalletInfo("device123");
  const balance = await stakeWallet.getBalance("device123");
  ```

- **Recover Tokens:**  
  The contract owner can recover tokens accidentally sent to the contract:
  ```javascript
  await stakeWallet.recoverTokens(tokenAddress, amount);
  ```

## Running Hardhat Tasks

- **Start Hardhat Node:**

```bash
npx hardhat node
```

- **Run Tests** (if tests are available):

```bash
npx hardhat test
```

Happy coding!
