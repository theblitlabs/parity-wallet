# Load environment variables
-include .env

.PHONY: all install build test clean deploy anvil format

# Main targets
all: install build test

# Setup and dependencies
install:
	git submodule update --init --recursive

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

# Network deployments (with verification)
deploy-sepolia: check-env
	forge script script/Deploy.s.sol:DeployScript \
		--rpc-url ${SEPOLIA_RPC_URL} \
		--private-key ${PRIVATE_KEY} \
		--broadcast \
		--verify \
		-vvvv

# Environment checks
check-env:
	@if [ -z "${PRIVATE_KEY}" ]; then \
		echo "Error: PRIVATE_KEY is required for network deployment"; \
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