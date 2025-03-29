// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/ParityWallet.sol";
import "../src/ParityWalletProxy.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/parity-token/src/ParityToken.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Deploy implementation
        ParityWallet implementation = new ParityWallet();
        console.log("Implementation deployed to:", address(implementation));

        // Step 2: Prepare initialization data
        bytes memory initData = abi.encodeWithSelector(
            ParityWallet.initialize.selector,
            tokenAddress
        );

        // Step 3: Deploy proxy with implementation and initialization
        ParityWalletProxy proxy = new ParityWalletProxy(
            address(implementation),
            initData
        );
        console.log("Proxy deployed to:", address(proxy));

        vm.stopBroadcast();

        console.log("Deployment completed!");
        console.log("Use this address for all interactions:", address(proxy));
    }
}

// Mock token for CI testing
contract MockParityToken is ERC20 {
    constructor() ERC20("Mock Parity Token", "MPT") {
        _mint(msg.sender, 1000000 * 10 ** 18);
    }
}
