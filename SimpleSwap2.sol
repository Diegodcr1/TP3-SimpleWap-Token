// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleSwap2 is ERC20 {
    struct Reserve {
        uint256 reserveA;
        uint256 reserveB;
    }

    mapping(address => mapping(address => Reserve)) public pools;

    constructor() ERC20("Simple LP Token", "SLP") {} 

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        require(block.timestamp <= deadline, "Expired");

        (address tokenX, address tokenY) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        Reserve storage pool = pools[tokenX][tokenY];

        if (pool.reserveA == 0 && pool.reserveB == 0) {
            amountA = amountADesired;
            amountB = amountBDesired;
        } else {
            uint256 optimalB = (amountADesired * pool.reserveB) / pool.reserveA;
            if (optimalB <= amountBDesired) {
                amountA = amountADesired;
                amountB = optimalB;
            } else {
                amountB = amountBDesired;
                amountA = (amountBDesired * pool.reserveA) / pool.reserveB;
            }
        }

      require(amountA >= amountAMin && amountB >= amountBMin, "Slippage too high");
     
        ERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        ERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        pool.reserveA += amountA;
        pool.reserveB += amountB;

        liquidity = sqrt(amountA * amountB);
        _mint(to, liquidity);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidityAmount,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB) {
        require(block.timestamp <= deadline, "Expired");

        (address tokenX, address tokenY) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        Reserve storage pool = pools[tokenX][tokenY];

        uint256 totalLPSupply = totalSupply();
        require(liquidityAmount > 0 && balanceOf(msg.sender) >= liquidityAmount, "Insufficient liquidity");

        amountA = (liquidityAmount * pool.reserveA) / totalLPSupply;
        amountB = (liquidityAmount * pool.reserveB) / totalLPSupply;

        require(amountA >= amountAMin && amountB >= amountBMin, "Slippage too high");

        _burn(msg.sender, liquidityAmount);

        pool.reserveA -= amountA;
        pool.reserveB -= amountB;

        ERC20(tokenA).transfer(to, amountA);
        ERC20(tokenB).transfer(to, amountB);
    }

    function swapExactTokensForTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut) {
        require(block.timestamp <= deadline, "Expired");
        require(tokenIn != tokenOut, "Invalid token pair");

        (address tokenX, address tokenY) = tokenIn < tokenOut ? (tokenIn, tokenOut) : (tokenOut, tokenIn);
        Reserve storage pool = pools[tokenX][tokenY];
        require(pool.reserveA > 0 && pool.reserveB > 0, "Empty pool");

        (uint256 reserveIn, uint256 reserveOut) = tokenIn < tokenOut
            ? (pool.reserveA, pool.reserveB)
            : (pool.reserveB, pool.reserveA);

        amountOut = (amountIn * reserveOut) / (reserveIn + amountIn);

        require(amountOut >= amountOutMin, "Insufficient output amount");

        ERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        ERC20(tokenOut).transfer(to, amountOut);

        if (tokenIn < tokenOut) {
            pool.reserveA += amountIn;
            pool.reserveB -= amountOut;
        } else {
            pool.reserveB += amountIn;
            pool.reserveA -= amountOut;
        }
    }

    function getPrice(
        address tokenA,
        address tokenB
    ) public view returns (uint256 priceAtoB, uint256 priceBtoA) {
        require(tokenA != tokenB, "Invalid pair");

        (address tokenX, address tokenY) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        Reserve storage pool = pools[tokenX][tokenY];
        require(pool.reserveA > 0 && pool.reserveB > 0, "Empty pool");

        if (tokenA < tokenB) {
            priceAtoB = (pool.reserveB * 1e18) / pool.reserveA;
            priceBtoA = (pool.reserveA * 1e18) / pool.reserveB;
        } else {
            priceAtoB = (pool.reserveA * 1e18) / pool.reserveB;
            priceBtoA = (pool.reserveB * 1e18) / pool.reserveA;
        }
    }
 
    function getAmountOut(
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) public view returns (uint256 amountOut) {
        require(tokenIn != tokenOut, "Invalid pair");

        (address tokenX, address tokenY) = tokenIn < tokenOut ? (tokenIn, tokenOut) : (tokenOut, tokenIn);
        Reserve storage pool = pools[tokenX][tokenY];
        require(pool.reserveA > 0 && pool.reserveB > 0, "Empty pool");

        (uint256 reserveIn, uint256 reserveOut) = tokenIn < tokenOut
            ? (pool.reserveA, pool.reserveB)
            : (pool.reserveB, pool.reserveA);

        amountOut = (amountIn * reserveOut) / (reserveIn + amountIn);
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
