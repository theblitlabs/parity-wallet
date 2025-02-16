# Parity Wallet

This repository contains a smart contract wallet implementation for managing token deposits, transfers, and withdrawals. The project is built with [Foundry](https://book.getfoundry.sh/) and leverages secure development practices for robust wallet management.

## Features

- **Wallet Management**: Secure implementation for managing token deposits and withdrawals
- **Device-based Identification**: Unique device IDs for wallet identification
- **Transfer System**: Secure transfer mechanism between wallets
- **Address Management**: Update withdrawal addresses for enhanced security
- **Token Recovery**: Emergency token recovery functionality for contract owner
- **Deployment Scripts**: Ready-to-use scripts for both local development and testnet deployments
- **Etherscan Verification**: Automatic integration for contract source verification
- **Environment Management**: Uses environment variables for secure handling of sensitive configurations

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation.html) installed
- An Ethereum wallet with testnet ETH (for deploying to networks like Sepolia)

## Setup & Installation

1. **Clone the repository with submodules:**

   ```bash
   git clone --recursive https://github.com/parity-wallet/parity-wallet.git
   cd parity-wallet
   ```

   If you've already cloned the repository without `--recursive`, run:

   ```bash
   make install
   ```

   This will initialize and update all required submodules.

2. **Dependencies:**
   The project uses git submodules for dependency management:

   - `forge-std`: Foundry's standard library for testing and scripting
     Dependencies are pinned to specific commits for reproducible builds.

3. **Updating Dependencies:**
   To update all dependencies to their latest versions:

   ```bash
   make update
   ```

4. **Configure Environment Variables:**
   - Copy the environment template:
     ```bash
     cp .env.example .env
     ```
   - Update `.env` with your credentials:
     ```
     PRIVATE_KEY="your wallet private key"
     SEPOLIA_RPC_URL="your RPC URL"
     TOKEN_ADDRESS="your token contract address"
     ```

## Documentation

For detailed Foundry usage, visit: https://book.getfoundry.sh/

## Usage

The project includes a Makefile for common operations. Here are the main commands:

### Development

```shell
# Build the project
$ make build

# Run tests
$ make test

# Run tests with gas reporting
$ make test-gas

# Format code
$ make format

# Clean build artifacts
$ make clean
```

### Deployment

```shell
# Start local node
$ make anvil

# Deploy to local network
$ make deploy-local

# Deploy to Sepolia testnet
$ make deploy-sepolia
```

Note: For testnet deployments, ensure your `.env` file is properly configured with `SEPOLIA_RPC_URL` and `PRIVATE_KEY`.

## Contract Functionality

The ParityWallet contract provides the following key functions:

### Core Functions

- **Add Funds:**

  ```solidity
  function addFunds(uint256 amount, string deviceId, address withdrawalAddress)
  ```

  Deposit tokens into a wallet identified by a device ID.

- **Transfer Payment:**

  ```solidity
  function transferPayment(string creatorDeviceId, string solverDeviceId, uint256 amount)
  ```

  Transfer funds between wallets using device IDs.

- **Withdraw Funds:**

  ```solidity
  function withdrawFunds(string deviceId, uint256 amount)
  ```

  Withdraw tokens to the designated withdrawal address.

- **Update Wallet Address:**
  ```solidity
  function updateWalletAddress(string deviceId, address newAddress)
  ```
  Update the withdrawal address for a wallet.

### Administrative Functions

- **Recover Tokens:**
  ```solidity
  function recoverTokens(address tokenAddress, uint256 amount)
  ```
  Allow contract owner to recover tokens accidentally sent to the contract.

## Development

This project uses [Git Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) for dependency management, ensuring reproducible builds and consistent development environments.

### Development Workflow

1. **Local Development:**

   ```bash
   # Start local node
   make anvil

   # Deploy locally
   make deploy-local
   ```

2. **Testing:**

   ```bash
   # Run all tests
   make test

   # Run with gas reporting
   make test-gas

   # Run with traces
   make trace
   ```

3. **Code Quality:**

   ```bash
   # Format code
   make format

   # Build and check sizes
   make sizes
   ```

## Best Practices & Security

### Security Considerations

- **Secure Credentials:** Never commit your `.env` file or expose private keys
- **Device ID Management:** Ensure unique device IDs for wallet identification
- **Withdrawal Controls:** Strict validation of withdrawal addresses and amounts
- **Emergency Recovery:** Token recovery system for contract owner
- **Automated Verification:** Etherscan verification in deployment process

### Development Guidelines

- **Testing:** Write comprehensive tests for all wallet functions
- **Gas Optimization:** Monitor gas usage with `make test-gas`
- **Code Style:** Use `make format` before committing
- **Dependencies:** Document any new dependencies added

### CI/CD Pipeline

- Automated testing on pull requests
- Security analysis
- Gas usage monitoring
- Testnet deployment verification

## Contributing

Contributions are welcome! Please open an issue or submit a pull request if you have any enhancements or bug fixes.

## License

This project is licensed under the MIT License.
