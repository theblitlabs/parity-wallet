// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/ParityWallet.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract DeployScript is Script {
    function run() external {
        // Check chain ID first
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        if (chainId == 31337) {
            // Local Anvil chain
            // Use default Anvil private key
            vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

            // Deploy mock token first
            MockParityToken mockToken = new MockParityToken();
            console.log("Mock token deployed to:", address(mockToken));

            // Deploy wallet using mock token
            ParityWallet wallet = new ParityWallet(address(mockToken));
            console.log("ParityWallet deployed to:", address(wallet));
        } else {
            // Network deployment - require environment variables
            uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
            address tokenAddress = vm.envAddress("TOKEN_ADDRESS");

            vm.startBroadcast(deployerPrivateKey);
            ParityWallet wallet = new ParityWallet(tokenAddress);
            console.log("ParityWallet deployed to:", address(wallet));
        }

        vm.stopBroadcast();
    }
}

// Mock token for local testing
contract MockParityToken is ERC20 {
    constructor() ERC20("Mock Parity Token", "MPT") {
        _mint(msg.sender, 1000000 * 10 ** 18);
    }
}
