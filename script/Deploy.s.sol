// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/ParityWallet.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/parity-token/src/ParityToken.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() external {
        uint256 deployerPrivateKey;
        address tokenAddress;
        bool isCI = vm.envOr("CI", false);

        // Try to get private key from environment, fallback to Anvil key for local/CI
        try vm.envUint("PRIVATE_KEY") returns (uint256 key) {
            deployerPrivateKey = key;
            console.log("Using private key from environment");
        } catch {
            deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
            console.log("Using default Anvil private key");
        }

        vm.startBroadcast(deployerPrivateKey);

        // For CI, use mock token. For local/network, use actual Parity token
        if (isCI) {
            console.log("Starting CI deployment...");
            // Deploy mock token for CI
            MockParityToken mockToken = new MockParityToken();
            tokenAddress = address(mockToken);
            console.log("Mock token deployed to:", tokenAddress);
        } else {
            console.log("Starting deployment...");
            // Try to get token address from environment for network deployment
            try vm.envAddress("TOKEN_ADDRESS") returns (address addr) {
                tokenAddress = addr;
                console.log("Using existing token at:", tokenAddress);
            } catch {
                // Deploy new Parity token for local deployment
                uint256 initialSupply = 100_000_000 * 10 ** 18; // 100M tokens
                ParityToken parityToken = new ParityToken(initialSupply);
                tokenAddress = address(parityToken);
                console.log("New Parity token deployed to:", tokenAddress);
                console.log("Initial supply:", initialSupply);
            }
        }

        // Deploy wallet using the appropriate token
        ParityWallet wallet = new ParityWallet(tokenAddress);
        console.log("ParityWallet deployed to:", address(wallet));

        vm.stopBroadcast();
    }
}

// Mock token for CI testing
contract MockParityToken is ERC20 {
    constructor() ERC20("Mock Parity Token", "MPT") {
        _mint(msg.sender, 1000000 * 10 ** 18);
    }
}
