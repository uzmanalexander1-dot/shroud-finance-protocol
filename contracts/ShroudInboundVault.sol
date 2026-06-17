// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "./interfaces/IERC20.sol";
import {IShroudSettlementHook} from "./interfaces/IShroudSettlementHook.sol";

/// @title ShroudInboundVault
/// @notice EVM inbound LP vault template for ShroudChain observed deposits.
/// @dev Emits deposit events for off-chain settlement agents. This contract does not custody XMR.
contract ShroudInboundVault {
    address public owner;
    address public treasury;
    IShroudSettlementHook public settlementHook;
    bool public paused;

    mapping(address => bool) public supportedToken;
    mapping(bytes32 => bool) public consumedCommitment;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event TreasuryUpdated(address indexed treasury);
    event SettlementHookUpdated(address indexed hook);
    event TokenSupportUpdated(address indexed token, bool supported);
    event Paused(bool paused);
    event NativeDeposit(
        bytes32 indexed routeId,
        bytes32 indexed orderCommitment,
        address indexed sender,
        uint256 amount
    );
    event TokenDeposit(
        bytes32 indexed routeId,
        bytes32 indexed orderCommitment,
        address indexed token,
        address sender,
        uint256 amount
    );
    event Sweep(address indexed token, address indexed to, uint256 amount);

    error NotOwner();
    error PausedVault();
    error UnsupportedToken();
    error ZeroAmount();
    error ZeroAddress();
    error CommitmentAlreadyUsed();
    error TransferFailed();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier whenNotPaused() {
        if (paused) revert PausedVault();
        _;
    }

    constructor(address initialTreasury) {
        if (initialTreasury == address(0)) revert ZeroAddress();
        owner = msg.sender;
        treasury = initialTreasury;
        emit OwnershipTransferred(address(0), msg.sender);
        emit TreasuryUpdated(initialTreasury);
    }

    receive() external payable {
        depositNative(bytes32(0), bytes32(0));
    }

    function depositNative(bytes32 routeId, bytes32 orderCommitment) public payable whenNotPaused {
        if (msg.value == 0) revert ZeroAmount();
        _consume(orderCommitment);
        emit NativeDeposit(routeId, orderCommitment, msg.sender, msg.value);
        _notify(routeId, address(0), msg.sender, msg.value, orderCommitment);
    }

    function depositToken(
        address token,
        uint256 amount,
        bytes32 routeId,
        bytes32 orderCommitment
    ) external whenNotPaused {
        if (!supportedToken[token]) revert UnsupportedToken();
        if (amount == 0) revert ZeroAmount();
        _consume(orderCommitment);
        if (!IERC20(token).transferFrom(msg.sender, address(this), amount)) revert TransferFailed();
        emit TokenDeposit(routeId, orderCommitment, token, msg.sender, amount);
        _notify(routeId, token, msg.sender, amount, orderCommitment);
    }

    function setSupportedToken(address token, bool supported) external onlyOwner {
        if (token == address(0)) revert ZeroAddress();
        supportedToken[token] = supported;
        emit TokenSupportUpdated(token, supported);
    }

    function setTreasury(address nextTreasury) external onlyOwner {
        if (nextTreasury == address(0)) revert ZeroAddress();
        treasury = nextTreasury;
        emit TreasuryUpdated(nextTreasury);
    }

    function setSettlementHook(address hook) external onlyOwner {
        settlementHook = IShroudSettlementHook(hook);
        emit SettlementHookUpdated(hook);
    }

    function setPaused(bool nextPaused) external onlyOwner {
        paused = nextPaused;
        emit Paused(nextPaused);
    }

    function transferOwnership(address nextOwner) external onlyOwner {
        if (nextOwner == address(0)) revert ZeroAddress();
        emit OwnershipTransferred(owner, nextOwner);
        owner = nextOwner;
    }

    function sweepNative(uint256 amount) external onlyOwner {
        uint256 value = amount == 0 ? address(this).balance : amount;
        (bool ok,) = treasury.call{value: value}("");
        if (!ok) revert TransferFailed();
        emit Sweep(address(0), treasury, value);
    }

    function sweepToken(address token, uint256 amount) external onlyOwner {
        uint256 value = amount == 0 ? IERC20(token).balanceOf(address(this)) : amount;
        if (!IERC20(token).transfer(treasury, value)) revert TransferFailed();
        emit Sweep(token, treasury, value);
    }

    function _consume(bytes32 orderCommitment) internal {
        if (orderCommitment == bytes32(0)) return;
        if (consumedCommitment[orderCommitment]) revert CommitmentAlreadyUsed();
        consumedCommitment[orderCommitment] = true;
    }

    function _notify(
        bytes32 routeId,
        address token,
        address sender,
        uint256 amount,
        bytes32 orderCommitment
    ) internal {
        if (address(settlementHook) != address(0)) {
            settlementHook.onInboundDeposit(routeId, token, sender, amount, orderCommitment);
        }
    }
}

