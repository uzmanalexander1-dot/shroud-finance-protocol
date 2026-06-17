// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title ShroudSettlementEvents
/// @notice Minimal event publisher for deterministic ShroudChain settlement records.
contract ShroudSettlementEvents {
    address public owner;

    enum Status {
        Pending,
        Detected,
        Sending,
        Complete,
        Failed
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OrderCommitted(bytes32 indexed shroudTxId, bytes32 indexed commitmentHash, bytes32 routeId);
    event OrderStatusUpdated(bytes32 indexed shroudTxId, Status status);
    event SettlementRecorded(bytes32 indexed shroudTxId, bytes32 settlementHash, uint256 completedAt);

    error NotOwner();
    error ZeroAddress();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function commitOrder(bytes32 shroudTxId, bytes32 commitmentHash, bytes32 routeId) external onlyOwner {
        emit OrderCommitted(shroudTxId, commitmentHash, routeId);
        emit OrderStatusUpdated(shroudTxId, Status.Pending);
    }

    function updateStatus(bytes32 shroudTxId, Status status) external onlyOwner {
        emit OrderStatusUpdated(shroudTxId, status);
    }

    function recordSettlement(bytes32 shroudTxId, bytes32 settlementHash) external onlyOwner {
        emit SettlementRecorded(shroudTxId, settlementHash, block.timestamp);
        emit OrderStatusUpdated(shroudTxId, Status.Complete);
    }

    function transferOwnership(address nextOwner) external onlyOwner {
        if (nextOwner == address(0)) revert ZeroAddress();
        emit OwnershipTransferred(owner, nextOwner);
        owner = nextOwner;
    }
}

