// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/ParityWallet.sol";
import "../src/ParityWalletProxy.sol";

contract DeployProxyScript is Script {
    function run() public {
        console.log("\n=== Proxy Deployment ===");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        address implementationAddress = vm.envAddress("IMPLEMENTATION_ADDRESS");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deployer:", deployer);
        console.log("Token Address:", tokenAddress);
        console.log("Implementation Address:", implementationAddress);

        vm.startBroadcast(deployerPrivateKey);

        // Prepare initialization data
        bytes memory initData = abi.encodeWithSelector(
            ParityWallet.initialize.selector,
            tokenAddress
        );

        // Deploy proxy with implementation and initialization
        ParityWalletProxy proxy = new ParityWalletProxy(
            implementationAddress,
            initData
        );
        console.log("Proxy deployed to:", address(proxy));

        vm.stopBroadcast();

        console.log("\n=== Deployment Complete! ===");
        console.log("Implementation Address:", implementationAddress);
        console.log("Proxy Address:", address(proxy));
    }
}
