// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title Token2 - Simple ERC20 token
/// @author Diego
/// @notice This contract creates an ERC20 token with name "Token" and symbol "TK".
/// @dev Inherits from OpenZeppelin's ERC20. Mints 1000 tokens to the deployer upon contract deployment.
contract Token2 is ERC20 {
    
    /// @notice Constructor that initializes the token with name "Token" and symbol "TK".
    /// @dev On deployment, mints 1000 tokens (adjusted to 18 decimals) to the deployer's address.
    constructor() ERC20("Token", "TK") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }
}
