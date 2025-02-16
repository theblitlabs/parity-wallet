// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/ParityWallet.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress;

        // For local deployment, use a mock token
        if (block.chainid == 31337) {
            // Anvil chain ID
            // Deploy a mock token
            vm.startBroadcast(deployerPrivateKey);
            MockParityToken mockToken = new MockParityToken();
            tokenAddress = address(mockToken);
            console.log("Mock token deployed to:", tokenAddress);
        } else {
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
