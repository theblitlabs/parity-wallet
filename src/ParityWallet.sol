// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract ParityWallet is Ownable {
    // Structure to store wallet details
    struct WalletInfo {
        uint256 balance;
        string deviceId;
        address walletAddress;
        bool exists;
    }

    // Mapping of device ID to wallet info
    mapping(string => WalletInfo) public wallets;

    // The ERC20 token contract
    IERC20 public immutable token;

    // Events
    event FundsAdded(string indexed deviceId, address indexed from, uint256 amount);
    event TaskPayment(string indexed creatorDeviceId, string indexed solverDeviceId, uint256 amount);
    event FundsWithdrawn(string indexed deviceId, address indexed to, uint256 amount);
    event TokenRecovered(address indexed tokenAddress, uint256 amount);

    constructor(address _tokenAddress) Ownable(msg.sender) {
        require(_tokenAddress != address(0), "Invalid token address");
        token = IERC20(_tokenAddress);
    }

    /**
     * @dev Allows users to add funds to their wallet
     * @param _amount Amount of tokens to add
     * @param _deviceId Device ID to associate with the wallet
     * @param _walletAddress Address for withdrawals
     */
    function addFunds(uint256 _amount, string memory _deviceId, address _walletAddress) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(bytes(_deviceId).length > 0, "Device ID cannot be empty");

        // Always update wallet address when adding funds
        wallets[_deviceId] = WalletInfo({
            balance: wallets[_deviceId].balance + _amount,
            deviceId: _deviceId,
            walletAddress: _walletAddress,
            exists: true
        });

        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        emit FundsAdded(_deviceId, msg.sender, _amount);
    }

    /**
     * @dev Transfers payment from creator to solver
     * @param _creatorDeviceId Device ID of the task creator
     * @param _solverDeviceId Device ID of the task solver
     * @param _amount Amount to transfer
     */
    function transferPayment(string memory _creatorDeviceId, string memory _solverDeviceId, uint256 _amount) external {
        require(checkDeviceExists(_creatorDeviceId), "Creator device not registered");
        require(wallets[_creatorDeviceId].balance >= _amount, "Insufficient balance");
        require(_amount > 0, "Amount must be greater than zero");

        wallets[_creatorDeviceId].balance -= _amount;

        if (!wallets[_solverDeviceId].exists) {
            wallets[_solverDeviceId] =
                WalletInfo({ balance: _amount, deviceId: _solverDeviceId, walletAddress: msg.sender, exists: true });
        } else {
            wallets[_solverDeviceId].balance += _amount;
        }

        emit TaskPayment(_creatorDeviceId, _solverDeviceId, _amount);
    }

    /**
     * @dev Allows users to withdraw funds to their wallet address
     * @param _deviceId Device ID associated with the wallet
     * @param _amount Amount to withdraw
     */
    function withdrawFunds(string memory _deviceId, uint256 _amount) external {
        WalletInfo storage wallet = wallets[_deviceId];
        require(wallet.exists, "No wallet found for device ID");
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= wallet.balance, "Insufficient balance");
        require(wallet.walletAddress != address(0), "No withdrawal address set");

        // Transfer tokens to wallet address
        require(token.transfer(wallet.walletAddress, _amount), "Transfer failed");

        // Update balance
        wallet.balance -= _amount;

        emit FundsWithdrawn(_deviceId, wallet.walletAddress, _amount);
    }

    /**
     * @dev Updates withdrawal wallet address
     * @param _deviceId Device ID of the wallet
     * @param _newWalletAddress New address for withdrawals
     */
    function updateWalletAddress(string memory _deviceId, address _newWalletAddress) external {
        require(_newWalletAddress != address(0), "Invalid wallet address");
        WalletInfo storage wallet = wallets[_deviceId];
        require(wallet.exists, "No wallet found for device ID");
        wallet.walletAddress = _newWalletAddress;
    }

    /**
     * @dev Returns wallet information for a device ID
     */
    function getWalletInfo(string memory _deviceId)
        external
        view
        returns (uint256 balance, string memory deviceId, address walletAddress, bool exists)
    {
        WalletInfo memory wallet = wallets[_deviceId];
        return (wallet.balance, wallet.deviceId, wallet.walletAddress, wallet.exists);
    }

    /**
     * @dev Get balance for a device ID
     */
    function getBalance(string memory _deviceId) external view returns (uint256) {
        return wallets[_deviceId].balance;
    }

    /**
     * @dev Allows the owner to recover accidentally sent tokens
     */
    function recoverTokens(address _tokenAddress, uint256 _amount) external onlyOwner {
        require(_tokenAddress != address(0), "Invalid token address");
        require(_amount > 0, "Amount must be greater than 0");
        IERC20(_tokenAddress).transfer(owner(), _amount);
        emit TokenRecovered(_tokenAddress, _amount);
    }

    function checkDeviceExists(string memory deviceId) private view returns (bool) {
        return wallets[deviceId].exists;
    }
}
