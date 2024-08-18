// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.19;

import {Ownable} from "@solady/src/auth/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC4337Factory} from "@solady/src/accounts/ERC4337Factory.sol";

/*
 * @title NEETH Faucet
 * @author Cattin0x
 * @notice A contract that allows users to claim NEETH tokens for their Nani account
 */

contract Faucet is Ownable {
    event TokensClaimed(address indexed claimer, uint256 amount);
    event Paused(address indexed by);
    event Unpaused(address indexed by);
    event TokensWithdrawn(address indexed to, uint256 amount);

    error Faucet__AlreadyClaimed();
    error Faucet__Empty();
    error Faucet__Paused();
    error Faucet__NotPaused();
    error Faucet__TransferFailed();

    ERC4337Factory public constant FACTORY = ERC4337Factory(0x0000000000009f1E546FC4A8F68eB98031846cb8);
    IERC20 public constant NEETH = IERC20(0x00000000000009B4AB3f1bC2b029bd7513Fbd8ED);
    uint256 public constant AMOUNT = 1e15;
    bool public s_isPaused;

    mapping(address => bool) public s_hasClaimed;

    constructor() {
        _initializeOwner(msg.sender);
    }

    /// @notice Allows users to claim NEETH tokens for their Nani account
    /// @dev This function calculates the Nani account address and transfers tokens to it
    function claimNEETH() external {
        if (s_isPaused) {
            revert Faucet__Paused();
        }
        if (s_hasClaimed[msg.sender]) {
            revert Faucet__AlreadyClaimed();
        }
        if (NEETH.balanceOf(address(this)) < AMOUNT) {
            revert Faucet__Empty();
        }
        bytes32 salt = bytes32(uint256(uint160(msg.sender)) << 96);
        address naniAccount = FACTORY.getAddress(salt);
        s_hasClaimed[msg.sender] = true;
        bool success = NEETH.transfer(naniAccount, AMOUNT);
        if(!success) {
            revert Faucet__TransferFailed();
        }
        emit TokensClaimed(naniAccount, AMOUNT);
    }

    /// @notice Allows the owner to pause the faucet
    /// @dev This function can only be called by the contract owner
    function pauseFaucet() external onlyOwner {
        if (s_isPaused) {
            revert Faucet__Paused();
        }
        s_isPaused = true;
        emit Paused(msg.sender);
    }

    /// @notice Allows the owner to unpause the faucet
    /// @dev This function can only be called by the contract owner
    function unpauseFaucet() external onlyOwner {
        if (!s_isPaused) {
            revert Faucet__NotPaused();
        }
        s_isPaused = false;
        emit Unpaused(msg.sender);
    }

    /// @notice Allows the owner to withdraw all NEETH tokens from the faucet
    /// @dev This function can only be called by the contract owner
    function withdrawAllNEETH() external onlyOwner {
        uint256 balance = NEETH.balanceOf(address(this));
        if (balance == 0) {
            revert Faucet__Empty();
        }
        NEETH.transfer(owner(), balance);
        emit TokensWithdrawn(owner(), balance);
    }
}
