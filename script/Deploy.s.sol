// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/ParityWallet.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() external {
        // Ensure we're only running on local network
        require(block.chainid == 31337, "This script is intended to run only on local Anvil network");

        console.log("Deploying to local Anvil chain (chainId: 31337)");
        vm.broadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

        // Deploy mock token first
        MockParityToken mockToken = new MockParityToken();
        console.log("Mock token deployed to:", address(mockToken));

        // Deploy wallet using mock token
        ParityWallet wallet = new ParityWallet(address(mockToken));
        console.log("ParityWallet deployed to:", address(wallet));
    }
}

// Mock token for local testing
contract MockParityToken is ERC20 {
    constructor() ERC20("Mock Parity Token", "MPT") {
        _mint(msg.sender, 1000000 * 10 ** 18);
    }
}
