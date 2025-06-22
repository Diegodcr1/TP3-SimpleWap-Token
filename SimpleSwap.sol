// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract SimpleSwap is ERC20 {
    struct Reserve {
        uint256 reserveA;
        uint256 reserveB;
    }

        mapping(bytes32 => Reserve) public pools;

    constructor() ERC20("Simple LP Token", "SLP") {}

    function _pairKey(address tokenA, address tokenB) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(tokenA < tokenB ? tokenA : tokenB, tokenA < tokenB ? tokenB : tokenA));
    }

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
        bytes32 key = _pairKey(tokenA, tokenB);
        Reserve storage pool = pools[key];

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

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
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

        bytes32 key = _pairKey(tokenA, tokenB);
        Reserve storage pool = pools[key];

        uint256 totalSupply = totalSupply(); 

        require(liquidityAmount > 0 && balanceOf(msg.sender) >= liquidityAmount, "Insufficient liquidity");

         amountA = (liquidityAmount * pool.reserveA) / totalSupply;
         amountB = (liquidityAmount * pool.reserveB) / totalSupply;

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

    bytes32 key = _pairKey(tokenIn, tokenOut);
    Reserve storage pool = pools[key];
    require(pool.reserveA > 0 && pool.reserveB > 0, "Empty pool");

    
    (uint256 reserveIn, uint256 reserveOut) = tokenIn < tokenOut
        ? (pool.reserveA, pool.reserveB)
        : (pool.reserveB, pool.reserveA);

    
    uint256 amountInWithFee = (amountIn * 997) / 1000;
    amountOut = (amountInWithFee * reserveOut) / (reserveIn + amountInWithFee);

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

    bytes32 key = _pairKey(tokenA, tokenB);
    Reserve storage pool = pools[key];

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

    bytes32 key = _pairKey(tokenIn, tokenOut);
    Reserve storage pool = pools[key];
    require(pool.reserveA > 0 && pool.reserveB > 0, "Empty pool");

    (uint256 reserveIn, uint256 reserveOut) = tokenIn < tokenOut
        ? (pool.reserveA, pool.reserveB)
        : (pool.reserveB, pool.reserveA);

    uint256 amountInWithFee = (amountIn * 997) / 1000;

    amountOut = (amountInWithFee * reserveOut) / (reserveIn + amountInWithFee);
}

}
