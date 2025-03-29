// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/ParityWallet.sol";
import "../src/ParityWalletProxy.sol";

contract DeployProxyScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy implementation
        ParityWallet implementation = new ParityWallet();

        // Encode initialization data
        bytes memory initData = abi.encodeWithSelector(
            ParityWallet.initialize.selector,
            tokenAddress
        );

        // Deploy proxy
        ParityWalletProxy proxy = new ParityWalletProxy(
            address(implementation),
            initData
        );

        vm.stopBroadcast();

        console.log("Implementation deployed to:", address(implementation));
        console.log("Proxy deployed to:", address(proxy));
    }
}
