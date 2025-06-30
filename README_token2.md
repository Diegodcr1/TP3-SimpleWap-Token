// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title Token2 - Token ERC20 simple
/// @author [Tu nombre o alias]
/// @notice Este contrato crea un token ERC20 con nombre "Token" y símbolo "TK".
/// @dev Hereda de OpenZeppelin ERC20. Se acuñan 1000 tokens al deployador del contrato.
contract token2 is ERC20 {
    
    /// @notice Constructor que inicializa el token con nombre "Token" y símbolo "TK".
    /// @dev Al momento del despliegue se acuñan 1000 tokens (ajustados a 18 decimales) al `msg.sender`.
    constructor() ERC20("Token", "TK") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }
}
