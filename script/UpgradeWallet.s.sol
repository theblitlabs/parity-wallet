// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/ParityWallet.sol";
import "../src/ParityWalletProxy.sol";
import "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";

contract UpgradeScript is Script {
    error InvalidPrivateKey();
    error EnvironmentError(string message);

    function setUp() public {}

    function run() public {
        console.log("\n=== Parity Wallet Upgrade ===");

        // Check if we're in CI environment
        bool isCI = _isCI();

        // Get and validate private key and proxy address
        uint256 deployerPrivateKey = _getPrivateKey();
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("\n=== Upgrade Information ===");
        console.log("Deployer:", deployer);
        console.log("Current Proxy:", proxyAddress);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy new implementation
        ParityWallet newImplementation = new ParityWallet();
        console.log("\nNew implementation deployed to:", address(newImplementation));

        // Cast proxy to UUPSUpgradeable for the upgrade
        UUPSUpgradeable proxy = UUPSUpgradeable(payable(proxyAddress));

        // Upgrade proxy to new implementation
        proxy.upgradeToAndCall(
            address(newImplementation),
            "" // No initialization data needed since already initialized
        );

        vm.stopBroadcast();

        console.log("\n=== Upgrade Successful! ===");
        console.log("New implementation deployed to:", address(newImplementation));
        console.log("Proxy upgraded at:", proxyAddress);

        // Save new implementation address to .env if not in CI
        if (!isCI) {
            _saveImplementationAddress(address(newImplementation));
        }

        // Deployment verification instructions
        string memory etherscanKey = vm.envOr("ETHERSCAN_API_KEY", string(""));
        if (block.chainid == 11155111 || block.chainid == 1) {
            console.log("\n=== Next Steps ===");
            console.log("1. New implementation address saved to .env");
            console.log("2. To verify on Etherscan, run:");

            if (bytes(etherscanKey).length > 0) {
                console.log(
                    string.concat(
                        "   forge verify-contract ",
                        vm.toString(address(newImplementation)),
                        " ParityWallet --chain ",
                        vm.toString(block.chainid),
                        " --api-key ",
                        etherscanKey
                    )
                );
            } else {
                console.log(
                    string.concat(
                        "   forge verify-contract ",
                        vm.toString(address(newImplementation)),
                        " ParityWallet --chain ",
                        vm.toString(block.chainid)
                    )
                );
            }
        }
    }

    function _isCI() internal view returns (bool) {
        try vm.envBool("CI") returns (bool ci) {
            return ci;
        } catch {
            return false;
        }
    }

    function _getPrivateKey() internal view returns (uint256) {
        bool isCI = _isCI();

        try vm.envUint("PRIVATE_KEY") returns (uint256 key) {
            if (key == 0) revert InvalidPrivateKey();
            return key;
        } catch {
            // Use default key for local testing or CI
            if (block.chainid == 31337 || isCI) {
                return 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
            }
            revert InvalidPrivateKey();
        }
    }

    function _saveImplementationAddress(address implementation) internal {
        string[] memory inputs = new string[](4);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = string.concat(
            "sed -i '' 's/^IMPLEMENTATION_ADDRESS=.*$/IMPLEMENTATION_ADDRESS=", vm.toString(implementation), "/' .env"
        );

        try vm.ffi(inputs) {
            console.log("New implementation address saved to .env");
        } catch {
            console.log("Warning: Could not save implementation address to .env");
        }
    }
}
