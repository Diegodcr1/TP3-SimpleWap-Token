// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title SimpleSwap2 - Basic Token Swap and Liquidity Pool Contract
/// @notice Allows users to add/remove liquidity and swap between two tokens
/// @dev Issues ERC20 LP tokens representing liquidity shares

contract SimpleSwap2 is ERC20 {

    /// @dev Stores the reserves for a given token pair
    struct Reserve {
        uint256 reserveA;
        uint256 reserveB;
    }

    /// @notice Mapping of token pairs to their liquidity pools
    mapping(address => mapping(address => Reserve)) public pools;

    /// @notice Initializes the LP token with name and symbol
    constructor() ERC20("Simple LP Token", "SLP") {}

    /// @notice Adds liquidity to a token pair
    /// @param tokenA Address of the first token
    /// @param tokenB Address of the second token
    /// @param amountADesired Desired amount of tokenA to deposit
    /// @param amountBDesired Desired amount of tokenB to deposit
    /// @param amountAMin Minimum acceptable amount of tokenA
    /// @param amountBMin Minimum acceptable amount of tokenB
    /// @param to Address to receive the LP tokens
    /// @param deadline Latest timestamp for the transaction to be valid
    /// @return amountA Actual amount of tokenA added
    /// @return amountB Actual amount of tokenB added
    /// @return liquidity Amount of LP tokens minted
    function addLiquidity(...

    /// @notice Removes liquidity from a token pair
    /// @param tokenA Address of the first token
    /// @param tokenB Address of the second token
    /// @param liquidityAmount Amount of LP tokens to burn
    /// @param amountAMin Minimum amount of tokenA to receive
    /// @param amountBMin Minimum amount of tokenB to receive
    /// @param to Address to receive the output tokens
    /// @param deadline Latest timestamp for the transaction to be valid
    /// @return amountA Amount of tokenA returned
    /// @return amountB Amount of tokenB returned
    function removeLiquidity(...

    /// @notice Swaps a fixed amount of tokenIn for at least amountOutMin of tokenOut
    /// @param tokenIn Address of the input token
    /// @param tokenOut Address of the output token
    /// @param amountIn Exact amount of tokenIn to swap
    /// @param amountOutMin Minimum acceptable output of tokenOut
    /// @param to Recipient of the tokenOut
    /// @param deadline Latest timestamp for the transaction to be valid
    /// @return amountOut Amount of tokenOut received
    function swapExactTokensForTokens(...

    /// @notice Returns the current price between two tokens
    /// @param tokenA Address of the first token
    /// @param tokenB Address of the second token
    /// @return priceAtoB Price of 1 tokenA in terms of tokenB
    /// @return priceBtoA Price of 1 tokenB in terms of tokenA
    function getPrice(...

    /// @notice Calculates the output amount for a given input
    /// @param amountIn Input amount of tokens
    /// @param tokenIn Address of the input token
    /// @param tokenOut Address of the output token
    /// @return amountOut Expected output amount based on reserves
    function getAmountOut(...

    /// @dev Computes the square root of a value using the Babylonian method
    /// @param x Input value
    /// @return y Approximate square root of x
    function sqrt(...
}

contract SimpleSwap is ERC20 {
    //This structure defines the reserves of a pair of tokens:
    struct Reserve {
        uint256 reserveA; // amount of tokenA stored in the pool.
        uint256 reserveB;// amount of tokenB stored in the pool.
    }
/*This mapping stores all the reserves of all token pairs:bytes32 is a unique key generated for each pair (explained below).The value is the Reserve structure, which keeps track of how many tokens there are of each type.It is made public to allow queries from outside the contract.Example: if a user creates a pool between DAI and USDC,
 this mapping will store the reserves associated with that pair.*/
        mapping(bytes32 => Reserve) public pools;
//This is the contract constructor, which is executed only once when deployed://"Simple LP Token" or something more representative of the token's role as liquidity proof.//function _pairKey(...) — Key generator for the pool
    constructor() ERC20("Simple LP Token", "SLP") {}

/*This function generates a unique key for a pair of tokens, regardless of the order in which they are passed:Use tokenA < tokenB to sort the addresses, 
ensuring consistency.abi.encodePacked(...) creates a concatenated byte sequence with both ordered addresses.keccak256(...) generates a hash (unique key) that will be used as an index in the pools mapping.Thus, both tokenA-tokenB and tokenB-tokenA end up generating the same key, avoiding duplicates.*/
   
    function _pairKey(address tokenA, address tokenB) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(tokenA < tokenB ? tokenA : tokenB, tokenA < tokenB ? tokenB : tokenA));
    }

/*This is the main user input:tokenA, tokenB: addresses of the tokens to be paired.amountADesired, amountBDesired: amounts you want to contribute.amountAMin, amountBMin: minimum acceptable amounts (protection against slippage).to: who will receive the liquidity tokens.deadline: time limit for execution.*/

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
        /*If the current block exceeds the defined limit, revert. It serves to prevent delayed operations.*/
        bytes32 key = _pairKey(tokenA, tokenB);
        Reserve storage pool = pools[key];
/*Calculate a unique key for the pair.
Access the reservation of that pair from the mapping.
*/
        if (pool.reserveA == 0 && pool.reserveB == 0) {
            amountA = amountADesired;
            amountB = amountBDesired;
        } 
        /*If it is the first time that this pool is created, the values are accepted as they come.*/
        else {
            uint256 optimalB = (amountADesired * pool.reserveB) / pool.reserveA;
            if (optimalB <= amountBDesired) {
                amountA = amountADesired;
                amountB = optimalB;
            } else {
                amountB = amountBDesired;
                amountA = (amountBDesired * pool.reserveA) / pool.reserveB;
            }
        }
/*This maintains the balance of the pool. Use a rule of three to adjust the desired values to the current proportion of tokens.*/
        require(amountA >= amountAMin && amountB >= amountBMin, "Slippage too high");
/*If the previous calculation results in amounts lower than the minimums accepted by the user, the operation fails.*/
        ERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        ERC20(tokenB).transferFrom(msg.sender, address(this), amountB);
/*Tokens are transferred from the user to the contract. It is necessary that the user has approved() beforehand*/
        pool.reserveA += amountA;
        pool.reserveB += amountB;
/*The amounts are added to the common fund of the contract.*/
        liquidity = sqrt(amountA * amountB);
        /*The square root of the product of the amounts is used. This provides a fair balance to represent the contribution.*/
        _mint(to, liquidity); 
    }
/*The LP tokens are delivered to the recipient as proof of their participation in the pool.*/
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        /*Use Newton's method to calculate a square root with precision. It is used to issue the correct amount of LP tokens.*/
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

/*Parameters:tokenA, tokenB: the tokens of the pair from which liquidity is to be withdrawn.
liquidityAmount: how many LP tokens the user wants to redeem.amountAMin, 
amountBMin: minimum amounts to be received (protection against slippage).
to: address that will receive the tokens.
deadline: time limit for this operation to be valid.*/
    function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidityAmount,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB) {

        /*It ensures that the transaction has not expired. If the deadline has passed, the operation is reversed.*/
      require(block.timestamp <= deadline, "Expired");

        bytes32 key = _pairKey(tokenA, tokenB);
        Reserve storage pool = pools[key];
    /*A unique key is generated to identify the pool and the associated Reserve structure is accessed*/
        uint256 totalSupply = totalSupply(); 
    /*The total number of LP tokens in circulation is obtained, which will be used to calculate the user's proportion.*/
        require(liquidityAmount > 0 && balanceOf(msg.sender) >= liquidityAmount, "Insufficient liquidity");
    /*Check that the user has enough LP tokens and that they are not trying to withdraw zero. If not, it reverts.*/
         amountA = (liquidityAmount * pool.reserveA) / totalSupply;
         amountB = (liquidityAmount * pool.reserveB) / totalSupply;
    /*Calculate what proportion of the reserves corresponds to the user, according to the LP tokens they provide. Basically, their percentage of the pool.*/
         require(amountA >= amountAMin && amountB >= amountBMin, "Slippage too high");
    /*Check that the calculated amounts are not below the accepted minimums. If they are, it is canceled.
    */
         _burn(msg.sender, liquidityAmount); 
    /*The contract destroys the LP tokens delivered by the user, thus reducing their participation in the pool.*/
         pool.reserveA -= amountA;
        pool.reserveB -= amountB;
    /*The tokens withdrawn are deducted from the total reserves of the pool.*/
          ERC20(tokenA).transfer(to, amountA);
          ERC20(tokenB).transfer(to, amountB);

          /*Finally, the contract transfers to the user the corresponding amount of tokenA and tokenB.*/
}

    function swapExactTokensForTokens(
        address tokenIn,// Token that the user provides
        address tokenOut,// Token that the user wants to receive
        uint256 amountIn,// Number of tokenIn to exchange
         uint256 amountOutMin,// Minimum that the user agrees to receive (protection against slippage)
        address to,// Destination of the output tokens
         uint256 deadline// Deadline for the transaction) external returns (uint256 amountOut)
    ) external returns (uint256 amountOut) {

        /*If the transaction is executed after the deadline, it is reverted. This protects the user against delays that may affect the price*/
    require(block.timestamp <= deadline, "Expired");
    require(tokenIn != tokenOut, "Invalid token pair");
        /*You cannot exchange the same token with itself*/
    bytes32 key = _pairKey(tokenIn, tokenOut);
    Reserve storage pool = pools[key];

    /*//A unique key is generated to identify the pool.//The reference to the pair reservation (tokenA, tokenB) is obtained.*/
    require(pool.reserveA > 0 && pool.reserveB > 0, "Empty pool");

    /*It is mandatory for the pool to have tokens available. If it is empty, a swap cannot be made. */
    (uint256 reserveIn, uint256 reserveOut) = tokenIn < tokenOut
        ? (pool.reserveA, pool.reserveB)
        : (pool.reserveB, pool.reserveA);

    /*Order the tokens by direction.Determine which is the input token (reserveIn) and output token (reserveOut) based on the relationship in the pool key.*/
    uint256 amountInWithFee = (amountIn * 997) / 1000;
    amountOut = (amountInWithFee * reserveOut) / (reserveIn + amountInWithFee);
    /*A fee of 0.3% applies (Uniswap uses 0.3% ⇒ leaving 99.7% of the actual value).*/

    /*Then apply the constant product formula to calculate how much can be withdrawn (amountOut) without breaking the balance of the pool.*/
    require(amountOut >= amountOutMin, "Insufficient output amount");

   /*Ensure that the user does not receive less than they are willing to accept. If the price changed too much, it is canceled*/
    
    ERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
    ERC20(tokenOut).transfer(to, amountOut);

    /*The contract receives input tokens from the user (requires approve authorization). Then it transfers the output tokens directly to the destination.*/
    
    if (tokenIn < tokenOut) {
        pool.reserveA += amountIn;
        pool.reserveB -= amountOut;
    } else {
        pool.reserveB += amountIn;
        pool.reserveA -= amountOut;
    }
    /*Add the input token to the reserve. Subtract the output token from the reserve. The order depends on the same criterion as the key of the pair. */

}
    /*The function is public and read-only (view), it does not modify the state of the contract.It returns two values:priceAtoB: how many tokens B are equivalent to 1 token A.priceBtoA: how many tokens A are equivalent to 1 token B.*/
    function getPrice(
    address tokenA,
    address tokenB
    ) public view returns (uint256 priceAtoB, uint256 priceBtoA) {
    require(tokenA != tokenB, "Invalid pair");

   /* It prevents the user from trying to calculate the price of a token against themselves, which makes no sense in this context.
*/
    bytes32 key = _pairKey(tokenA, tokenB);
    /*A unique key (hash) is generated to identify the pool that relates tokenA and tokenB. It ensures that the order does not affect the result (tokenA vs tokenB or vice versa is the same pool).*/
    Reserve storage pool = pools[key];

    /*Access the Reserve structure where the amounts of tokens available in that liquidity pair are stored.

*/
    require(pool.reserveA > 0 && pool.reserveB > 0, "Empty pool");

    /*Avoid divisions by zero. If there are no reserves in either of the two tokens, a valid price cannot be calculated.

*/
    if (tokenA < tokenB) {
        priceAtoB = (pool.reserveB * 1e18) / pool.reserveA;
        priceBtoA = (pool.reserveA * 1e18) / pool.reserveB;
    } 
    //It ensures to follow the same ordering criterion when comparing addresses (tokenA < tokenB).
    //The price is calculated with precision using 18 decimals, by multiplying by 1e18. This is a convention to handle fractions between integers without losing precision.
    //The price is calculated as the quotient between reserves:

    else
     {
        priceAtoB = (pool.reserveA * 1e18) / pool.reserveB;
        priceBtoA = (pool.reserveB * 1e18) / pool.reserveA;
    }
    //Así podés saber cuántos tokens B valen 1 token A, y al revés.
}



    function getAmountOut( // It will convert tokenA to tokenB, so that it can be converted
          uint256 amountIn,// Amount of tokenA to be converted into tokensB.uint256
            address tokenIn,// The token being converted from.uint256
            address tokenOut// The token being converted to.uint256
    ) public view returns (uint256 amountOut) {
    require(tokenIn != tokenOut, "Invalid pair");// If the token pair is different, this operation cannot be made.It prevents the user from using a token to itself.

    bytes32 key = _pairKey(tokenIn, tokenOut);// A unique key is generated to identify the pool that relates tokenA and token
    Reserve storage pool = pools[key];// The pool is referenced by its key, which is stored in the pools mapping
    require(pool.reserveA > 0 && pool.reserveB > 0, "Empty pool");// Avoid divisions by zero. If there are no reserves in either of the

    (uint256 reserveIn, uint256 reserveOut) = tokenIn < tokenOut
        ? (pool.reserveA, pool.reserveB)
        : (pool.reserveB, pool.reserveA);// Order the tokens by direction.Determine which is the input token and

    uint256 amountInWithFee = (amountIn * 997) / 1000;// A fee of 3% is applied, as Uniswap uses

    amountOut = (amountInWithFee * reserveOut) / (reserveIn + amountInWithFee);// Apply the constant product formula to calculate how much can be withdrawn without breaking
}

}
