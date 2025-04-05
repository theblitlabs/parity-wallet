// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/ParityWallet.sol";
import "../src/ParityWalletProxy.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/parity-token/src/ParityToken.sol";

contract DeployScript is Script {
    error InvalidPrivateKey();
    error EnvironmentError(string message);

    function setUp() public {}

    function run() public {
        console.log("\n=== Parity Wallet Deployment ===");

        // Check if we're in CI environment
        bool isCI = _isCI();

        // Get and validate private key and token address
        uint256 deployerPrivateKey = _getPrivateKey();
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("\n=== Deployment Information ===");
        console.log("Deployer:", deployer);
        console.log("Token Address:", tokenAddress);

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Deploy implementation
        ParityWallet implementation = new ParityWallet();
        console.log("\nImplementation deployed to:", address(implementation));

        // Step 2: Prepare initialization data
        bytes memory initData = abi.encodeWithSelector(ParityWallet.initialize.selector, tokenAddress);

        // Step 3: Deploy proxy with implementation and initialization
        ParityWalletProxy proxy = new ParityWalletProxy(address(implementation), initData);

        vm.stopBroadcast();

        console.log("\n=== Deployment Successful! ===");
        console.log("Implementation deployed to:", address(implementation));
        console.log("Proxy deployed to:", address(proxy));

        // Save addresses to .env if not in CI
        if (!isCI) {
            _saveAddresses(address(proxy), address(implementation));
        }

        // Deployment verification instructions
        string memory etherscanKey = vm.envOr("ETHERSCAN_API_KEY", string(""));
        if (block.chainid == 11155111 || block.chainid == 1) {
            console.log("\n=== Next Steps ===");
            console.log("1. Proxy address saved to .env");
            console.log("2. To verify on Etherscan, run:");

            if (bytes(etherscanKey).length > 0) {
                console.log(
                    string.concat(
                        "   forge verify-contract ",
                        vm.toString(address(implementation)),
                        " ParityWallet --chain ",
                        vm.toString(block.chainid),
                        " --api-key ",
                        etherscanKey
                    )
                );
                console.log(
                    string.concat(
                        "   forge verify-contract ",
                        vm.toString(address(proxy)),
                        " ParityWalletProxy --chain ",
                        vm.toString(block.chainid),
                        " --api-key ",
                        etherscanKey
                    )
                );
            } else {
                console.log(
                    string.concat(
                        "   forge verify-contract ",
                        vm.toString(address(implementation)),
                        " ParityWallet --chain ",
                        vm.toString(block.chainid)
                    )
                );
                console.log(
                    string.concat(
                        "   forge verify-contract ",
                        vm.toString(address(proxy)),
                        " ParityWalletProxy --chain ",
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

    function _saveAddresses(address proxy, address implementation) internal {
        string[] memory proxyInputs = new string[](4);
        proxyInputs[0] = "bash";
        proxyInputs[1] = "-c";
        proxyInputs[2] = string.concat("sed -i '' 's/^PROXY_ADDRESS=.*$/PROXY_ADDRESS=", vm.toString(proxy), "/' .env");

        string[] memory implInputs = new string[](4);
        implInputs[0] = "bash";
        implInputs[1] = "-c";
        implInputs[2] = string.concat(
            "sed -i '' 's/^IMPLEMENTATION_ADDRESS=.*$/IMPLEMENTATION_ADDRESS=", vm.toString(implementation), "/' .env"
        );

        try vm.ffi(proxyInputs) {
            console.log("Proxy address saved to .env");
            try vm.ffi(implInputs) {
                console.log("Implementation address saved to .env");
            } catch {
                console.log("Warning: Could not save implementation address to .env");
            }
        } catch {
            console.log("Warning: Could not save addresses to .env");
        }
    }
}

// Mock token for CI testing
contract MockParityToken is ERC20 {
    constructor() ERC20("Mock Parity Token", "MPT") {
        _mint(msg.sender, 1000000 * 10 ** 18);
    }
}
