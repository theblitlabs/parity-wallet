# Parity Wallet for Filecoin

This repository contains an upgradeable smart contract wallet implementation for managing token deposits, transfers, and withdrawals on Filecoin networks. The project is built with [Foundry](https://book.getfoundry.sh/) and leverages secure development practices for robust wallet management on both Filecoin Calibration testnet and Mainnet.

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

## Deployed Contracts

### Filecoin Calibration Testnet

- **Proxy Address**: `0x7465E7a637f66cb7b294B856A25bc84aBfF1d247` (Use this address for all interactions)
- **Implementation Address**: `0xb313488120e72F1217453a62AD825d90b0542cFC`
- **Token Address**: `0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0`

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
     FILECOIN_CALIBRATION_RPC_URL=          # Example: https://api.calibration.node.glif.io/rpc/v1
     FILECOIN_MAINNET_RPC_URL=              # Example: https://api.node.glif.io/rpc/v1

     # Deployment Account (required)
     PRIVATE_KEY=                           # Your private key (with 0x prefix)

     # Contract Addresses (required)
     TOKEN_ADDRESS=                         # The ERC20 token contract address
     PROXY_ADDRESS=                         # The proxy contract address (required for upgrades)
     IMPLEMENTATION_ADDRESS=                # The current implementation contract address (auto-updated)
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

# Deploy to Filecoin Calibration testnet
$ make deploy-filecoin-calibration

# Deploy to Filecoin Mainnet
$ make deploy-filecoin-mainnet

# Upgrade implementation on local network
$ make upgrade-proxy-local

# Upgrade implementation on Filecoin Calibration
$ make upgrade-filecoin-calibration

# Upgrade implementation on Filecoin Mainnet
$ make upgrade-filecoin-mainnet
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
   ```

## Deployment Guide

This project supports deployment to Filecoin networks (Calibration testnet and Mainnet). Below are detailed instructions for each deployment method.

### Prerequisites

Before deploying, ensure you have:

1. **Foundry installed** - [Installation guide](https://book.getfoundry.sh/getting-started/installation.html)
2. **Private key with sufficient gas tokens**:
   - For Filecoin Calibration: tFIL from [Calibration faucet](https://faucet.calibration.fildev.network)
   - For Filecoin Mainnet: FIL tokens
3. **Token contract address** for the wallet to manage
4. **Filecoin RPC endpoint** for your target network

### Method 1: Using Deployment Scripts (Recommended)

#### Step 1: Configure Environment

1. **Copy the environment template:**

   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` with your configuration:**

   ```bash
   # For Filecoin Calibration
   FILECOIN_CALIBRATION_RPC_URL=https://api.calibration.node.glif.io/rpc/v1
   PRIVATE_KEY=0x27087208dce7240c053effc3b6e696a5e8dc1a2da5ef0a180f82aff979864bf3
   TOKEN_ADDRESS=0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0

   # For Filecoin Mainnet
   FILECOIN_MAINNET_RPC_URL=https://api.node.glif.io/rpc/v1
   PRIVATE_KEY=0x27087208dce7240c053effc3b6e696a5e8dc1a2da5ef0a180f82aff979864bf3
   TOKEN_ADDRESS=0x...
   ```

#### Step 2: Deploy to Filecoin Networks

**For Local Development:**

```bash
# Start local node
make anvil

# Deploy proxy system
make deploy-proxy-local
```

**For Filecoin Networks:**

```bash
# Using Makefile (recommended)
make deploy-filecoin-calibration    # For Calibration testnet
make deploy-filecoin-mainnet        # For Mainnet

# Or using script deployment directly
export PRIVATE_KEY='0x27087208dce7240c053effc3b6e696a5e8dc1a2da5ef0a180f82aff979864bf3'
export TOKEN_ADDRESS='0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0'

# Deploy to Filecoin Calibration
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url https://api.calibration.node.glif.io/rpc/v1 \
  --broadcast --skip-simulation

# Deploy to Filecoin Mainnet
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url https://api.node.glif.io/rpc/v1 \
  --broadcast --skip-simulation
```

### Method 2: Manual Contract Deployment

For more control or troubleshooting, you can deploy contracts individually:

#### Step 1: Build Contracts

```bash
forge build
```

#### Step 2: Deploy Implementation Contract

```bash
# Set environment variables
export PRIVATE_KEY='0x...'

# Deploy ParityWallet implementation
forge create \
  --rpc-url https://api.calibration.node.glif.io/rpc/v1 \
  --private-key $PRIVATE_KEY \
  src/ParityWallet.sol:ParityWallet \
  --broadcast

# Save the deployed implementation address (e.g., 0xb313488120e72F1217453a62AD825d90b0542cFC)
```

#### Step 3: Deploy Proxy Contract

```bash
# Set variables
IMPLEMENTATION_ADDRESS=0xb313488120e72F1217453a62AD825d90b0542cFC
TOKEN_ADDRESS=0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0

# Create initialization data (encode initialize function call)
INIT_DATA=$(cast calldata "initialize(address)" $TOKEN_ADDRESS)

# Deploy proxy with initialization
forge create \
  --rpc-url https://api.calibration.node.glif.io/rpc/v1 \
  --private-key $PRIVATE_KEY \
  src/ParityWalletProxy.sol:ParityWalletProxy \
  --constructor-args $IMPLEMENTATION_ADDRESS $INIT_DATA \
  --broadcast

# Save the deployed proxy address (e.g., 0x7465E7a637f66cb7b294B856A25bc84aBfF1d247)
```

### Deployment Verification

After deployment, verify the contracts are working correctly:

#### 1. Check Implementation Address

```bash
# Verify proxy points to correct implementation
cast implementation 0x7465E7a637f66cb7b294B856A25bc84aBfF1d247 \
  --rpc-url https://api.calibration.node.glif.io/rpc/v1
```

#### 2. Check Token Address

```bash
# Verify token address is set correctly
cast call 0x7465E7a637f66cb7b294B856A25bc84aBfF1d247 "token()" \
  --rpc-url https://api.calibration.node.glif.io/rpc/v1
```

#### 3. Check Owner

```bash
# Verify deployer is the owner
cast call 0x7465E7a637f66cb7b294B856A25bc84aBfF1d247 "owner()" \
  --rpc-url https://api.calibration.node.glif.io/rpc/v1
```

### Network-Specific Configuration

#### Filecoin Networks

**Calibration Testnet:**

- **Chain ID**: 314159
- **RPC URL**: `https://api.calibration.node.glif.io/rpc/v1`
- **Explorer**: [Filfox Calibration](https://calibration.filfox.info/)
- **Faucet**: [Calibration Faucet](https://faucet.calibration.fildev.network)

**Filecoin Mainnet:**

- **Chain ID**: 314
- **RPC URL**: `https://api.node.glif.io/rpc/v1`
- **Explorer**: [Filfox](https://filfox.info/)

### Troubleshooting Deployment

#### Common Issues and Solutions

1. **Gas Limit Error on Filecoin:**

   ```
   Error: GasLimit field cannot be less than the cost of storing a message on chain
   ```

   **Solution**: Filecoin automatically calculates gas. The error usually resolves on retry.

2. **Nonce Behind Error:**

   ```
   Error: provider nonce (X) is still behind expected nonce (Y)
   ```

   **Solution**: This is common on Filecoin networks and doesn't affect successful deployment.

3. **Private Key Format:**

   - Ensure private key includes `0x` prefix
   - Example: `0x27087208dce7240c053effc3b6e696a5e8dc1a2da5ef0a180f82aff979864bf3`

4. **RPC Connection Issues:**
   - Verify RPC URL is accessible
   - Try alternative endpoints if available
   - Check network connectivity

#### Success Indicators

Look for these indicators of successful deployment:

```bash
✅  [Success] Hash: 0x...
Contract Address: 0x...
Block: 12345
```

The deployment script will output:

```bash
=== Deployment Successful! ===
Implementation deployed to: 0x...
Proxy deployed to: 0x...
```

### Post-Deployment Steps

1. **Save Contract Addresses:**

   - Update your `.env` file with deployed addresses
   - Keep a record of both proxy and implementation addresses

2. **Verify on Explorer:**

   - Check transactions on the relevant blockchain explorer
   - Verify contract creation and initialization

3. **Test Basic Functionality:**
   ```bash
   # Test a view function
   cast call <PROXY_ADDRESS> "token()" --rpc-url <RPC_URL>
   ```

### Initial Deployment Summary

This process deploys:

- **ParityWallet implementation contract**: Contains the wallet logic
- **ParityWalletProxy contract**: UUPS proxy that delegates to implementation
- **Initialization**: Proxy is initialized with the specified token address

The proxy address is what users should interact with, and it remains constant even when the implementation is upgraded.

### Upgrading the Contract

When you need to upgrade the wallet implementation:

1. **Deploy New Implementation:**

   ```bash
   # For local development
   make upgrade-proxy-local

   # For Sepolia testnet
   make upgrade-proxy-sepolia
   ```

   This will:

   - Deploy the new implementation contract
   - Call `upgradeTo()` on the proxy to point to the new implementation
   - Update `IMPLEMENTATION_ADDRESS` in your .env

2. **Verify Upgrade:**
   - Check that the proxy is pointing to the new implementation
   - Verify that existing state is preserved
   - Test new functionality through the proxy address

### Important Notes

- Always test upgrades on a local network first
- Keep track of all implementation addresses for future reference
- The proxy address remains constant across upgrades
- All user interactions should always use the proxy address
- State is preserved in the proxy during upgrades

### Deployment Configuration

Make sure your `.env` file is properly configured before deployment:

```bash
# Required for deployment
PRIVATE_KEY=0x27087208dce7240c053effc3b6e696a5e8dc1a2da5ef0a180f82aff979864bf3
TOKEN_ADDRESS=0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0

# Filecoin Network RPC URLs
FILECOIN_CALIBRATION_RPC_URL=https://api.calibration.node.glif.io/rpc/v1
FILECOIN_MAINNET_RPC_URL=https://api.node.glif.io/rpc/v1

# Contract addresses (auto-updated after deployment)
PROXY_ADDRESS=0x7465E7a637f66cb7b294B856A25bc84aBfF1d247
IMPLEMENTATION_ADDRESS=0xb313488120e72F1217453a62AD825d90b0542cFC
```

### Quick Deployment Examples

**Deploy to Filecoin Calibration (Recommended for testing):**

```bash
# 1. Set environment variables
export PRIVATE_KEY='0x27087208dce7240c053effc3b6e696a5e8dc1a2da5ef0a180f82aff979864bf3'
export TOKEN_ADDRESS='0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0'
export FILECOIN_CALIBRATION_RPC_URL='https://api.calibration.node.glif.io/rpc/v1'

# 2. Deploy using Makefile
make deploy-filecoin-calibration

# 3. Or deploy using script directly
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url https://api.calibration.node.glif.io/rpc/v1 \
  --broadcast --skip-simulation
```

**Deploy to Filecoin Mainnet:**

```bash
# 1. Set environment variables
export PRIVATE_KEY='0x27087208dce7240c053effc3b6e696a5e8dc1a2da5ef0a180f82aff979864bf3'
export TOKEN_ADDRESS='0x...'  # Your mainnet token address
export FILECOIN_MAINNET_RPC_URL='https://api.node.glif.io/rpc/v1'

# 2. Deploy using Makefile
make deploy-filecoin-mainnet
```

### Post-Deployment Verification

After deployment or upgrade:

1. **Verify Implementation:**

   ```bash
   # Get the implementation address from the proxy
   cast implementation <PROXY_ADDRESS>
   ```

2. **Verify Initialization:**

   ```bash
   # Check if the token address is set correctly
   cast call <PROXY_ADDRESS> "token()" --rpc-url <RPC_URL>
   ```

3. **Verify Ownership:**
   ```bash
   # Check if ownership is set correctly
   cast call <PROXY_ADDRESS> "owner()" --rpc-url <RPC_URL>
   ```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request if you have any enhancements or bug fixes.

## License

This project is licensed under the MIT License.
