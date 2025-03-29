// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/ParityWallet.sol";
import "../src/ParityWalletProxy.sol";
import "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";

contract UpgradeScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy new implementation
        ParityWallet newImplementation = new ParityWallet();

        // Cast proxy to UUPSUpgradeable for the upgrade
        UUPSUpgradeable proxy = UUPSUpgradeable(payable(proxyAddress));

        // Upgrade proxy to new implementation
        proxy.upgradeToAndCall(
            address(newImplementation),
            "" // No initialization data needed since already initialized
        );

        vm.stopBroadcast();

        console.log(
            "New implementation deployed to:",
            address(newImplementation)
        );
        console.log("Proxy upgraded at:", proxyAddress);
    }
}
