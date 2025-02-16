// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/ParityWallet.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockParityToken is ERC20 {
    constructor() ERC20("Mock Parity Token", "MPT") {
        _mint(msg.sender, 1000000 * 10 ** 18);
    }
}

contract ParityWalletTest is Test {
    ParityWallet public wallet;
    MockParityToken public token;
    address public user;
    uint256 public constant INITIAL_BALANCE = 1000 * 10 ** 18;
    string constant TEST_DEVICE_ID = "test_device_1";

    function setUp() public {
        token = new MockParityToken();
        wallet = new ParityWallet(address(token));
        user = makeAddr("user");

        // Transfer some tokens to test user
        token.transfer(user, INITIAL_BALANCE);
        vm.label(address(token), "Parity Token");
        vm.label(address(wallet), "Parity Wallet");
        vm.label(user, "Test User");
    }

    function testAddFunds() public {
        uint256 depositAmount = 100 * 10 ** 18;

        vm.startPrank(user);
        token.approve(address(wallet), depositAmount);
        wallet.addFunds(depositAmount, TEST_DEVICE_ID, user);
        vm.stopPrank();

        (uint256 balance, , , bool exists) = wallet.getWalletInfo(
            TEST_DEVICE_ID
        );
        assertEq(
            balance,
            depositAmount,
            "Incorrect wallet balance after deposit"
        );
        assertEq(
            token.balanceOf(user),
            INITIAL_BALANCE - depositAmount,
            "Incorrect user balance after deposit"
        );
        assertTrue(exists, "Wallet should exist");
    }

    function testWithdrawFunds() public {
        uint256 depositAmount = 100 * 10 ** 18;
        uint256 withdrawAmount = 50 * 10 ** 18;

        // First deposit
        vm.startPrank(user);
        token.approve(address(wallet), depositAmount);
        wallet.addFunds(depositAmount, TEST_DEVICE_ID, user);

        // Then withdraw
        wallet.withdrawFunds(TEST_DEVICE_ID, withdrawAmount);
        vm.stopPrank();

        (uint256 balance, , , bool exists) = wallet.getWalletInfo(
            TEST_DEVICE_ID
        );
        assertEq(
            balance,
            depositAmount - withdrawAmount,
            "Incorrect wallet balance after withdrawal"
        );
        assertEq(
            token.balanceOf(user),
            INITIAL_BALANCE - depositAmount + withdrawAmount,
            "Incorrect user balance after withdrawal"
        );
        assertTrue(exists, "Wallet should exist");
    }

    function test_RevertWhen_WithdrawInsufficientBalance() public {
        uint256 depositAmount = 100 * 10 ** 18;
        uint256 withdrawAmount = 200 * 10 ** 18;

        vm.startPrank(user);
        token.approve(address(wallet), depositAmount);
        wallet.addFunds(depositAmount, TEST_DEVICE_ID, user);

        vm.expectRevert("Insufficient balance");
        wallet.withdrawFunds(TEST_DEVICE_ID, withdrawAmount);
        vm.stopPrank();
    }

    function test_RevertWhen_ZeroDeposit() public {
        vm.prank(user);
        vm.expectRevert("Amount must be greater than 0");
        wallet.addFunds(0, TEST_DEVICE_ID, user);
    }

    function test_RevertWhen_ZeroWithdraw() public {
        // First create a wallet
        uint256 depositAmount = 100 * 10 ** 18;
        vm.startPrank(user);
        token.approve(address(wallet), depositAmount);
        wallet.addFunds(depositAmount, TEST_DEVICE_ID, user);

        vm.expectRevert("Amount must be greater than 0");
        wallet.withdrawFunds(TEST_DEVICE_ID, 0);
        vm.stopPrank();
    }
}
