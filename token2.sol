// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract token2 is ERC20 {
    constructor(string memory name, string memory sym)
     ERC20(name, sym) {}

     function mint (address to, uint256 amount) public { 
         _mint(to, amount);   
        
    }
  
   
}
