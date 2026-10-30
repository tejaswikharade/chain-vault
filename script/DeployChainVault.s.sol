// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ChainVault} from "../contracts/ChainVault.sol";

interface Vm {
    function startBroadcast() external;
    function stopBroadcast() external;
}

contract DeployChainVault {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function run(address beneficiary, uint256 unlockTime) external returns (ChainVault vault) {
        vm.startBroadcast();
        vault = new ChainVault(beneficiary, unlockTime);
        vm.stopBroadcast();
    }
}
