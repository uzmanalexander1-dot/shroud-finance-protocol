// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IShroudSettlementHook {
    function onInboundDeposit(
        bytes32 routeId,
        address token,
        address sender,
        uint256 amount,
        bytes32 orderCommitment
    ) external;
}

