# Load environment variables
-include .env

.PHONY: all install build test clean deploy anvil format deploy-proxy upgrade-proxy

# Main targets
all: install build test

# Setup and dependencies
install:
	forge install

# Build and test
build:
	forge build

test:
	forge test -vv

test-gas:
	forge test -vv --gas-report

test-trace:
	forge test -vvv

test-match:
	forge test --match-$(type) $(pattern) -vvv

clean:
	forge clean

# Deployment
anvil:
	anvil

anvil-fork:
	anvil --fork-url ${RPC_URL}

# Local deployment (no verification needed)
deploy-local:
	forge script script/Deploy.s.sol:DeployScript \
		--rpc-url http://localhost:8545 \
		--broadcast \
		--ffi

# Proxy deployment and upgrade commands
deploy-proxy-local:
	forge script script/DeployProxy.s.sol:DeployProxyScript \
		--rpc-url http://localhost:8545 \
		--broadcast \
		--ffi

upgrade-proxy-local:
	forge script script/UpgradeWallet.s.sol:UpgradeScript \
		--rpc-url http://localhost:8545 \
		--broadcast \
		--ffi

# Filecoin deployment commands
deploy-filecoin-calibration: check-env check-token
	forge script script/Deploy.s.sol:DeployScript \
		--rpc-url ${FILECOIN_CALIBRATION_RPC_URL} \
		--private-key ${PRIVATE_KEY} \
		--broadcast \
		--skip-simulation \
		-vvvv

deploy-filecoin-mainnet: check-env check-token
	forge script script/Deploy.s.sol:DeployScript \
		--rpc-url ${FILECOIN_MAINNET_RPC_URL} \
		--private-key ${PRIVATE_KEY} \
		--broadcast \
		--skip-simulation \
		-vvvv

upgrade-filecoin-calibration: check-env check-proxy
	forge script script/UpgradeWallet.s.sol:UpgradeScript \
		--rpc-url ${FILECOIN_CALIBRATION_RPC_URL} \
		--private-key ${PRIVATE_KEY} \
		--broadcast \
		--skip-simulation \
		-vvvv

upgrade-filecoin-mainnet: check-env check-proxy
	forge script script/UpgradeWallet.s.sol:UpgradeScript \
		--rpc-url ${FILECOIN_MAINNET_RPC_URL} \
		--private-key ${PRIVATE_KEY} \
		--broadcast \
		--skip-simulation \
		-vvvv

# Environment checks
check-env:
	@if [ -z "${PRIVATE_KEY}" ]; then \
		echo "Error: PRIVATE_KEY is required for network deployment"; \
		exit 1; \
	fi

check-token:
	@if [ -z "${TOKEN_ADDRESS}" ]; then \
		echo "Error: TOKEN_ADDRESS is required for deployment"; \
		echo "Please set TOKEN_ADDRESS=0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0"; \
		exit 1; \
	fi

check-proxy:
	@if [ -z "${PROXY_ADDRESS}" ]; then \
		echo "Error: PROXY_ADDRESS is required for upgrades"; \
		exit 1; \
	fi

# Development tools
format:
	forge fmt

update:
	git submodule update --remote --merge
	forge update

abi:
	@forge build
	@mkdir -p abi
	@jq -r '.abi' out/ParityWallet.sol/ParityWallet.json > abi/ParityWallet.json

verify:
	forge verify-contract ${CONTRACT_ADDRESS} ${CONTRACT_NAME} ${ETHERSCAN_API_KEY} --chain-id ${CHAIN_ID}

# Analysis
sizes:
	forge build --sizes

storage:
	forge inspect ${CONTRACT_NAME} storage-layout

flatten:
	forge flatten --output flattened.sol ${CONTRACT_PATH}