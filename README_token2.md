// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title token2 - Simple ERC20 Token with Minting Capability
/// @notice This contract allows minting of ERC20 tokens to any address
/// @dev Inherits from OpenZeppelin's ERC20 implementation
contract token2 is ERC20 {

    /// @notice Deploys the token contract with a name and symbol
    /// @param name Name of the ERC20 token
    /// @param sym Symbol of the ERC20 token
    constructor(string memory name, string memory sym)
        ERC20(name, sym)
    {}

    /// @notice Mints tokens to a specified address
    /// @dev This function is public and does not include access control—anyone can call it
    /// @param to Address that will receive the minted tokens
    /// @param amount Number of tokens to mint (in smallest unit, i.e., wei if 18 decimals)
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
}
