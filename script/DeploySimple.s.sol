// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/ParityWallet.sol";
import "../src/ParityWalletProxy.sol";

contract DeploySimpleScript is Script {
    function run() public {
        console.log("\n=== Simple Parity Wallet Deployment ===");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deployer:", deployer);
        console.log("Token Address:", tokenAddress);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy implementation only
        ParityWallet implementation = new ParityWallet();
        console.log("Implementation deployed to:", address(implementation));

        vm.stopBroadcast();

        console.log("\n=== Next Steps ===");
        console.log(
            "1. Update .env with IMPLEMENTATION_ADDRESS=",
            address(implementation)
        );
        console.log("2. Run proxy deployment script separately");
    }
}
