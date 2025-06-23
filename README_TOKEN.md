token.sol

//Smart contract in Solidity for a custom mintable ERC-20 token. Let's break it down step by step so you understand each part:

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//Import the ERC20 contract from the OpenZeppelin library, which contains the already proven logic for a standard token. This allows you to use all the functionality of ERC20 without having to rewrite it.

contract MyToken is ERC20 {

constructor(string memory name, string memory sym) ERC20(name, sym) {}

/*When you deploy this contract, you pass two parameters:name: name of the token (e.g. "TokenA")sym: symbol of the token (e.g. "TKA")*/

function mint(address to, uint256 amount) public {
    _mint(to, amount);
}

/*This function allows minting new tokens and sending them to any address. amount is written in units with decimals included, so if your token has 18 decimals, to mint 100 tokens you should pass 100 * 1e18. */

