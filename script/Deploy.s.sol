// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/ParityWallet.sol";
import "lib/parity-token/src/ParityToken.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() external {
        uint256 deployerPrivateKey;
        address tokenAddress;

        deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        console.log("Starting deployment...");
        vm.startBroadcast(deployerPrivateKey);

        try vm.envAddress("TOKEN_ADDRESS") returns (address addr) {
            tokenAddress = addr;
            console.log("Using existing token at:", tokenAddress);
        } catch {
            uint256 initialSupply = vm.envOr("INITIAL_SUPPLY", uint256(100_000_000 * 10 ** 18));
            ParityToken token = new ParityToken(initialSupply);
            tokenAddress = address(token);
            console.log("New ParityToken deployed to:", tokenAddress);
            console.log("Initial supply:", initialSupply);
        }

        // Deploy wallet using the token address
        ParityWallet wallet = new ParityWallet(tokenAddress);
        console.log("ParityWallet deployed to:", address(wallet));

        vm.stopBroadcast();
    }
}
