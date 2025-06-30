// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract SimpleSwap2 is ERC20 {
    
    constructor() ERC20("Token", "tk") {} 

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
        require(deadline  >=  block.timestamp, "Expired");
        liquidity=totalSupply();
    
       if (liquidity>0) {
                uint256 optimalA=(amountADesired * liquidity) /  ERC20(tokenA).balanceOf(address(this));
                uint256 optimalB=(amountBDesired * liquidity) / ERC20(tokenB).balanceOf(address(this));
        
            if (optimalA < optimalB) {
                amountA = amountADesired;
                amountB = getPrice(tokenA, tokenB) * amountA;
            } else {
                amountB = amountBDesired;
                amountA = getPrice(tokenB, tokenA) * amountB;
            }
            } else {
                liquidity=amountADesired;
                 amountA=amountADesired;
                 amountB=amountBDesired;

            }

            require(amountAMin<=amountA);
            require(amountBMin<=amountB);
            ERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
            ERC20(tokenB).transferFrom(msg.sender, address(this), amountB);
             _mint(to, liquidity);
    }
        
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB) {
        require( deadline >= block.timestamp, "Expired");
        uint256 totalLPliquidity = totalSupply();

        amountA = liquidity * ERC20(tokenA).balanceOf(address(this))/totalLPliquidity;
        amountB = liquidity * ERC20(tokenB).balanceOf(address(this))/totalLPliquidity;

        require(amountAMin<=amountA);
        require(amountBMin<=amountB);

        _burn(msg.sender, liquidity);
        ERC20(tokenA).transfer(to, amountA);
        ERC20(tokenB).transfer(to, amountB);
      
    }

    function swapExactTokensForTokens(
       
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) {
        require(deadline  >= block.timestamp, "Expired");

        ERC20 tokenA= ERC20(path[0]);
        ERC20 tokenB= ERC20(path[1]);
       

        uint256 amountOut = amountIn * tokenB.balanceOf(address(this)) / (amountIn+tokenA.balanceOf(address(this)));

        require(amountOut >= amountOutMin, "Insufficient output amount");

        tokenA.transferFrom(msg.sender, address(this), amountIn);
        tokenB.transfer(to, amountOut);

        amounts=new uint[](2);
         amounts[0]=amountIn;
         amounts[1]=amountOut;
    }

    function getPrice(
        address tokenA,
        address tokenB
    ) public view returns (uint price) {
       
         uint256 amount1= ERC20(tokenA).balanceOf(address(this));
         uint256 amount2= ERC20(tokenB).balanceOf(address(this));
         return (amount2*1e18)/amount1;
        
    }
 
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) 
                    external pure returns (uint amountOut ) 
    {
              amountOut=amountIn*reserveOut/(amountIn+reserveIn);
    }
   
}
