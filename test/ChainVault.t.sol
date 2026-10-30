// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ChainVault} from "../contracts/ChainVault.sol";

interface Vm {
    function warp(uint256) external;
    function deal(address account, uint256 newBalance) external;
    function prank(address caller) external;
}

/// @dev Lightweight tests without a forge-std dependency.
contract ChainVaultTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant BENEFICIARY = address(0xBEEF);
    address private constant OUTSIDER = address(0xCAFE);
    uint256 private unlockTime;
    ChainVault private vault;

    function setUp() public {
        unlockTime = block.timestamp + 7 days;
        vault = new ChainVault(BENEFICIARY, unlockTime);
        vm.deal(address(this), 10 ether);
    }

    function testOwnerCanFundVaultOnce() public {
        vault.deposit{value: 1 ether}();
        require(address(vault).balance == 1 ether, "funds not received");
        require(vault.vaultBalance() == 1 ether, "balance view mismatch");
    }

    function testOnlyOwnerCanDeposit() public {
        vm.deal(OUTSIDER, 1 ether);
        vm.prank(OUTSIDER);
        (bool ok,) = address(vault).call{value: 1 ether}(abi.encodeCall(vault.deposit, ()));
        require(!ok, "outsider deposited");
    }

    function testCannotReleaseBeforeUnlock() public {
        vault.deposit{value: 1 ether}();
        vm.prank(BENEFICIARY);
        (bool ok,) = address(vault).call(abi.encodeCall(vault.release, ()));
        require(!ok, "released too early");
    }

    function testBeneficiaryCanReleaseAfterUnlock() public {
        vault.deposit{value: 2 ether}();
        uint256 balanceBefore = BENEFICIARY.balance;
        vm.warp(unlockTime);
        vm.prank(BENEFICIARY);
        vault.release();

        require(BENEFICIARY.balance == balanceBefore + 2 ether, "beneficiary not paid");
        require(vault.released(), "release state missing");
        require(address(vault).balance == 0, "vault not emptied");
    }

    function testOwnerCanCancelBeforeUnlock() public {
        vault.deposit{value: 1 ether}();
        uint256 balanceBefore = address(this).balance;
        vault.cancel();

        require(address(this).balance == balanceBefore + 1 ether, "owner not refunded");
        require(vault.cancelled(), "cancel state missing");
    }

    function testCannotCancelAtOrAfterUnlock() public {
        vault.deposit{value: 1 ether}();
        vm.warp(unlockTime);
        (bool ok,) = address(vault).call(abi.encodeCall(vault.cancel, ()));
        require(!ok, "cancelled after unlock");
    }

    function testFinalizedVaultRejectsFurtherActions() public {
        vault.deposit{value: 1 ether}();
        vault.cancel();
        (bool deposited,) = address(vault).call{value: 1 ether}(abi.encodeCall(vault.deposit, ()));
        require(!deposited, "funded finalized vault");
    }
}
