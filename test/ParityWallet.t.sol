// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/ParityWallet.sol";
import "./mocks/MockToken.sol";

contract ParityWalletTest is Test {
    ParityWallet public wallet;
    MockToken public token;
    address public owner;
    address public user;

    function setUp() public {
        owner = address(this);
        user = address(0x1);
        vm.label(owner, "Owner");
        vm.label(user, "User");

        // Deploy mock token
        token = new MockToken();

        // Deploy and initialize wallet
        wallet = new ParityWallet();
        wallet.initialize(address(token));

        // Give user some tokens
        token.mint(user, 1000 ether);
        vm.prank(user);
        token.approve(address(wallet), type(uint256).max);
    }

    function testAddFunds() public {
        uint256 depositAmount = 100 * 10 ** 18;

        vm.startPrank(user);
        token.approve(address(wallet), depositAmount);
        wallet.addFunds(depositAmount, "test_device_1", user);
        vm.stopPrank();

        (uint256 balance, , , bool exists) = wallet.getWalletInfo(
            "test_device_1"
        );
        assertEq(
            balance,
            depositAmount,
            "Incorrect wallet balance after deposit"
        );
        assertEq(
            token.balanceOf(user),
            1000 ether - depositAmount,
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
        wallet.addFunds(depositAmount, "test_device_1", user);

        // Then withdraw
        wallet.withdrawFunds("test_device_1", withdrawAmount);
        vm.stopPrank();

        (uint256 balance, , , bool exists) = wallet.getWalletInfo(
            "test_device_1"
        );
        assertEq(
            balance,
            depositAmount - withdrawAmount,
            "Incorrect wallet balance after withdrawal"
        );
        assertEq(
            token.balanceOf(user),
            1000 ether - depositAmount + withdrawAmount,
            "Incorrect user balance after withdrawal"
        );
        assertTrue(exists, "Wallet should exist");
    }

    function test_RevertWhen_WithdrawInsufficientBalance() public {
        uint256 depositAmount = 100 * 10 ** 18;
        uint256 withdrawAmount = 200 * 10 ** 18;

        vm.startPrank(user);
        token.approve(address(wallet), depositAmount);
        wallet.addFunds(depositAmount, "test_device_1", user);

        vm.expectRevert("Insufficient balance");
        wallet.withdrawFunds("test_device_1", withdrawAmount);
        vm.stopPrank();
    }

    function test_RevertWhen_ZeroDeposit() public {
        vm.prank(user);
        vm.expectRevert("Amount must be greater than 0");
        wallet.addFunds(0, "test_device_1", user);
    }

    function test_RevertWhen_ZeroWithdraw() public {
        // First create a wallet
        uint256 depositAmount = 100 * 10 ** 18;
        vm.startPrank(user);
        token.approve(address(wallet), depositAmount);
        wallet.addFunds(depositAmount, "test_device_1", user);

        vm.expectRevert("Amount must be greater than 0");
        wallet.withdrawFunds("test_device_1", 0);
        vm.stopPrank();
    }
}
