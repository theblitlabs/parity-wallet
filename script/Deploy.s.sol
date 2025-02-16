// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/ParityWallet.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey;
        address tokenAddress;

        // For local deployment, use default key
        if (block.chainid == 31337) {
            // Anvil chain ID
            // Use default Anvil private key if not provided
            try vm.envUint("PRIVATE_KEY") returns (uint256 key) {
                deployerPrivateKey = key;
            } catch {
                deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
            }

            // Deploy a mock token
            vm.startBroadcast(deployerPrivateKey);
            MockParityToken mockToken = new MockParityToken();
            tokenAddress = address(mockToken);
            console.log("Mock token deployed to:", tokenAddress);
        } else {
            deployerPrivateKey = vm.envUint("PRIVATE_KEY");
            tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        }

        // Deploy the wallet
        ParityWallet wallet = new ParityWallet(tokenAddress);
        console.log("ParityWallet deployed to:", address(wallet));

        vm.stopBroadcast();
    }
}

// Mock token for local testing
contract MockParityToken is ERC20 {
    constructor() ERC20("Mock Parity Token", "MPT") {
        _mint(msg.sender, 1000000 * 10 ** 18);
    }
}
