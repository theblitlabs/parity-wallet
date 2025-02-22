// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/ParityWallet.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() external {
        // Get private key from command line args
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress;

        console.log("Starting deployment...");
        vm.startBroadcast(deployerPrivateKey);

        // For local deployment, deploy a mock token
        if (block.chainid == 31337) {
            MockParityToken mockToken = new MockParityToken();
            tokenAddress = address(mockToken);
            console.log("Mock token deployed to:", tokenAddress);
        } else {
            // For network deployment, use token address from env
            tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        }

        // Deploy wallet using the appropriate token address
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
