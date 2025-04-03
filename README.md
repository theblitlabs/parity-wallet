# Parity Wallet

This repository contains an upgradeable smart contract wallet implementation for managing token deposits, transfers, and withdrawals. The project is built with [Foundry](https://book.getfoundry.sh/) and leverages secure development practices for robust wallet management.

## Features

- **Upgradeable Contract**: Uses UUPS proxy pattern for future upgrades
- **Wallet Management**: Secure implementation for managing token deposits and withdrawals
- **Device-based Identification**: Unique device IDs for wallet identification
- **Transfer System**: Secure transfer mechanism between wallets
- **Address Management**: Update withdrawal addresses for enhanced security
- **Token Recovery**: Emergency token recovery functionality for contract owner
- **Deployment Scripts**: Ready-to-use scripts for both local development and testnet deployments
- **Etherscan Verification**: Automatic integration for contract source verification
- **Environment Management**: Uses environment variables for secure handling of sensitive configurations
- **Auto-updating Addresses**: Automatically tracks deployed contract addresses in .env

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation.html) installed
- An Ethereum wallet with testnet ETH (for deploying to networks like Sepolia)

## Setup & Installation

1. **Clone the repository with submodules:**

   ```bash
   git clone --recursive https://github.com/theblitlabs/parity-wallet.git
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
   - `openzeppelin-contracts`: For secure contract implementations
   - `openzeppelin-contracts-upgradeable`: For upgradeable contract patterns
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
   - Required variables in `.env`:

     ```bash
     # RPC Endpoints (required)
     SEPOLIA_RPC_URL=                       # Example: https://1rpc.io/sepolia

     # Deployment Account (required)
     PRIVATE_KEY=                           # Your private key (with 0x prefix)

     # Contract Addresses (required)
     TOKEN_ADDRESS=                         # The ERC20 token contract address
     PROXY_ADDRESS=                         # The proxy contract address (required for upgrades)
     IMPLEMENTATION_ADDRESS=                # The current implementation contract address (auto-updated)

     # Verification (optional)
     ETHERSCAN_API_KEY=                    # For contract verification on Etherscan
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

# Deploy to local network with proxy
$ make deploy-proxy-local

# Deploy to Sepolia testnet with proxy
$ make deploy-proxy-sepolia

# Upgrade implementation on local network
$ make upgrade-proxy-local

# Upgrade implementation on Sepolia testnet
$ make upgrade-proxy-sepolia
```

Note: The deployment scripts will automatically update your `.env` file with the newly deployed contract addresses:

- `PROXY_ADDRESS`: Updated when deploying a new proxy
- `IMPLEMENTATION_ADDRESS`: Updated when deploying or upgrading the implementation

## Contract Architecture

The ParityWallet system uses the UUPS (Universal Upgradeable Proxy Standard) pattern with two main contracts:

### ParityWalletProxy

- Handles all user interactions
- Delegates calls to the implementation
- Maintains contract state
- Remains at a fixed address

### ParityWallet (Implementation)

- Contains the actual logic
- Can be upgraded while maintaining state
- Users never interact with this directly

### Core Functions

All functions should be called through the proxy address:

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

   # Deploy with proxy locally (uses --ffi to update .env)
   make deploy-proxy-local
   ```

2. **Testing:**

   ```bash
   # Run all tests
   make test

   # Run with gas reporting
   make test-gas

   # Run with traces
   make test-trace
   ```

3. **Upgrading Contract:**
   ```bash
   # After making changes to the implementation
   make upgrade-proxy-local    # For local testing (updates IMPLEMENTATION_ADDRESS)
   make upgrade-proxy-sepolia  # For testnet (updates IMPLEMENTATION_ADDRESS)
   ```

### Best Practices & Security

#### Environment Management

- Keep `.env` file secure and never commit it
- Use `.env.example` as a template for required variables
- Contract addresses are automatically tracked in `.env`
- Verify environment variables before deployment
- Use the provided Makefile commands for consistent deployment

#### Proxy Pattern Best Practices

- Always interact with the proxy address, not the implementation
- Keep track of both proxy and implementation addresses
- Test upgrades thoroughly before deploying to mainnet
- Use proper initialization through the proxy
- Never initialize the implementation contract directly

#### Security Considerations

- **Secure Credentials:** Never commit your `.env` file or expose private keys
- **Proxy Safety:** Ensure proper access controls for upgrades
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
