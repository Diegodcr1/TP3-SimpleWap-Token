// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title SimpleSwap2
/// @author Diego
/// @notice AMM contract that enables swaps between two ERC20 tokens and liquidity management.
/// @dev Inspired by Uniswap . No swap fees and supports only one token pair.

contract SimpleSwap2 is ERC20 {

    /// @notice Deploys the LP token with name "Token" and symbol "tk".
    constructor() ERC20("Token", "tk") {}

    /// @notice Adds liquidity to the pool using two ERC20 tokens.
    /// @param tokenA Address of the first token.
    /// @param tokenB Address of the second token.
    /// @param amountADesired Desired amount of token A to deposit.
    /// @param amountBDesired Desired amount of token B to deposit.
    /// @param amountAMin Minimum acceptable amount of token A to prevent slippage.
    /// @param amountBMin Minimum acceptable amount of token B to prevent slippage.
    /// @param to Address that will receive the LP tokens.
    /// @param deadline Timestamp by which the transaction must be executed.
    /// @return amountA Actual amount used of token A.
    /// @return amountB Actual amount used of token B.
    /// @return liquidity Amount of LP tokens minted.
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity) {
        require(deadline >= block.timestamp, "Expired");
        liquidity = totalSupply();

        if (liquidity > 0) {
            uint256 optimalA = (amountADesired * liquidity) / ERC20(tokenA).balanceOf(address(this));
            uint256 optimalB = (amountBDesired * liquidity) / ERC20(tokenB).balanceOf(address(this));

            if (optimalA < optimalB) {
                amountA = amountADesired;
                amountB = (getPrice(tokenA, tokenB) * amountA) / 1e18;
            } else {
                amountB = amountBDesired;
                amountA = (getPrice(tokenB, tokenA) * amountB) / 1e18;
            }
        } else {
            amountA = amountADesired;
            amountB = amountBDesired;
            liquidity = amountADesired;
        }

        require(amountA >= amountAMin, "Insufficient A");
        require(amountB >= amountBMin, "Insufficient B");

        ERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        ERC20(tokenB).transferFrom(msg.sender, address(this), amountB);
        _mint(to, liquidity);
    }

    /// @notice Removes liquidity from the pool and returns the proportional tokens.
    /// @param tokenA Address of the first token.
    /// @param tokenB Address of the second token.
    /// @param liquidity Amount of LP tokens to burn.
    /// @param amountAMin Minimum acceptable amount of token A to receive.
    /// @param amountBMin Minimum acceptable amount of token B to receive.
    /// @param to Address that will receive the underlying tokens.
    /// @param deadline Timestamp by which the transaction must be executed.
    /// @return amountA Transferred amount of token A.
    /// @return amountB Transferred amount of token B.
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB) {
        require(deadline >= block.timestamp, "Expired");

        uint256 totalLP = totalSupply();
        amountA = liquidity * ERC20(tokenA).balanceOf(address(this)) / totalLP;
        amountB = liquidity * ERC20(tokenB).balanceOf(address(this)) / totalLP;

        require(amountA >= amountAMin, "Insufficient A");
        require(amountB >= amountBMin, "Insufficient B");

        _burn(msg.sender, liquidity);
        ERC20(tokenA).transfer(to, amountA);
        ERC20(tokenB).transfer(to, amountB);
    }

    /// @notice Swaps an exact amount of one token for another based on reserves.
    /// @param amountIn Amount of input tokens.
    /// @param amountOutMin Minimum acceptable amount of output tokens.
    /// @param path Array with input and output token addresses (length must be 2).
    /// @param to Address to receive the output tokens.
    /// @param deadline Timestamp by which the swap must occur.
    /// @return amounts Array with input and output amounts used in the swap.
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) {
        require(deadline >= block.timestamp, "Expired");
        require(path.length == 2, "Invalid path");

        ERC20 tokenA = ERC20(path[0]);
        ERC20 tokenB = ERC20(path[1]);

        uint reserveA = tokenA.balanceOf(address(this));
        uint reserveB = tokenB.balanceOf(address(this));

        uint amountOut = amountIn * reserveB / (amountIn + reserveA);
        require(amountOut >= amountOutMin, "Insufficient output");

        tokenA.transferFrom(msg.sender, address(this), amountIn);
        tokenB.transfer(to, amountOut);

        amounts = new uint[](2);
        amounts[0] = amountIn;
        amounts[1] = amountOut;
    }

    /// @notice Returns the price of one token in terms of another with 18 decimals.
    /// @param tokenA Base token address.
    /// @param tokenB Quote token address.
    /// @return price Price of tokenA in terms of tokenB (18 decimals).
    function getPrice(address tokenA, address tokenB) public view returns (uint price) {
        uint amount1 = ERC20(tokenA).balanceOf(address(this));
        uint amount2 = ERC20(tokenB).balanceOf(address(this));
        require(amount1 > 0, "Zero reserve");
        price = (amount2 * 1e18) / amount1;
    }

    /// @notice Estimates output amount using constant product formula.
    /// @param amountIn Input token amount.
    /// @param reserveIn Reserve of input token.
    /// @param reserveOut Reserve of output token.
    /// @return amountOut Estimated output token amount.
    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut) {
        amountOut = amountIn * reserveOut / (amountIn + reserve
