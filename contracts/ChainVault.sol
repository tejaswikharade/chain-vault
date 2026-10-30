// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title ChainVault
/// @notice A minimal ETH vault: the owner funds it, the beneficiary releases it after a set time.
contract ChainVault {
    error NotOwner();
    error NotBeneficiary();
    error InvalidBeneficiary();
    error InvalidUnlockTime();
    error VaultFinalized();
    error VaultAlreadyFunded();
    error UnlockTimeNotReached();
    error UnlockTimeReached();
    error ZeroDeposit();
    error TransferFailed();
    error ReentrantCall();

    address public immutable owner;
    address public immutable beneficiary;
    uint256 public immutable unlockTime;
    bool public released;
    bool public cancelled;

    uint256 private _locked = 1;

    event Deposited(address indexed depositor, uint256 amount);
    event Released(address indexed beneficiary, uint256 amount, uint256 releasedAt);
    event Cancelled(address indexed owner, uint256 amount, uint256 cancelledAt);

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier onlyBeneficiary() {
        if (msg.sender != beneficiary) revert NotBeneficiary();
        _;
    }

    modifier nonReentrant() {
        if (_locked != 1) revert ReentrantCall();
        _locked = 2;
        _;
        _locked = 1;
    }

    /// @param beneficiary_ Address authorized to release funds after unlockTime_.
    /// @param unlockTime_ Unix timestamp after which the beneficiary may release funds.
    constructor(address beneficiary_, uint256 unlockTime_) {
        if (beneficiary_ == address(0)) revert InvalidBeneficiary();
        if (unlockTime_ <= block.timestamp) revert InvalidUnlockTime();

        owner = msg.sender;
        beneficiary = beneficiary_;
        unlockTime = unlockTime_;
    }

    /// @notice Fund the vault once. Restricting deposits to the owner makes cancellation refunds unambiguous.
    function deposit() public payable onlyOwner {
        if (released || cancelled) revert VaultFinalized();
        if (address(this).balance - msg.value != 0) revert VaultAlreadyFunded();
        if (msg.value == 0) revert ZeroDeposit();

        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Lets owner send ETH with an ordinary transfer while retaining the deposit rules.
    receive() external payable {
        deposit();
    }

    /// @notice Send all vault ETH to the beneficiary once the unlock time has passed.
    function release() external onlyBeneficiary nonReentrant {
        if (released || cancelled) revert VaultFinalized();
        if (block.timestamp < unlockTime) revert UnlockTimeNotReached();

        released = true;
        uint256 amount = address(this).balance;
        (bool sent,) = payable(beneficiary).call{value: amount}("");
        if (!sent) revert TransferFailed();

        emit Released(beneficiary, amount, block.timestamp);
    }

    /// @notice Recover all vault ETH to the owner before the unlock time.
    function cancel() external onlyOwner nonReentrant {
        if (released || cancelled) revert VaultFinalized();
        if (block.timestamp >= unlockTime) revert UnlockTimeReached();

        cancelled = true;
        uint256 amount = address(this).balance;
        (bool sent,) = payable(owner).call{value: amount}("");
        if (!sent) revert TransferFailed();

        emit Cancelled(owner, amount, block.timestamp);
    }

    function vaultBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
