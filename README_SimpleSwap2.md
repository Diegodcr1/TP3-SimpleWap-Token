// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title SimpleSwap2
/// @author [Tu nombre]
/// @notice Permite intercambios entre dos tokens ERC20 y manejo de liquidez.
/// @dev Inspirado en AMM tipo Uniswap v1 sin comisiones de intercambio.
contract SimpleSwap2 is ERC20 {
    
    /// @notice Crea el token LP con nombre "Token" y símbolo "tk".
    constructor() ERC20("Token", "tk") {} 

    /// @notice Agrega liquidez al pool usando dos tokens ERC20.
    /// @param tokenA Dirección del token A.
    /// @param tokenB Dirección del token B.
    /// @param amountADesired Monto deseado del token A.
    /// @param amountBDesired Monto deseado del token B.
    /// @param amountAMin Monto mínimo aceptable del token A.
    /// @param amountBMin Monto mínimo aceptable del token B.
    /// @param to Dirección que recibirá los tokens LP.
    /// @param deadline Fecha límite para ejecutar la transacción.
    /// @return amountA Monto real usado del token A.
    /// @return amountB Monto real usado del token B.
    /// @return liquidity Tokens LP acuñados.
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
        ...
    }

    /// @notice Retira liquidez del pool y devuelve los tokens proporcionales.
    /// @param tokenA Dirección del token A.
    /// @param tokenB Dirección del token B.
    /// @param liquidity Cantidad de tokens LP a quemar.
    /// @param amountAMin Monto mínimo aceptable del token A.
    /// @param amountBMin Monto mínimo aceptable del token B.
    /// @param to Dirección que recibirá los tokens subyacentes.
    /// @param deadline Fecha límite para ejecutar la transacción.
    /// @return amountA Monto transferido de token A.
    /// @return amountB Monto transferido de token B.
    function removeLiquidity(
        ...
    ) external returns (uint amountA, uint amountB) {
        ...
    }

    /// @notice Intercambia una cantidad fija de un token por otro.
    /// @param amountIn Cantidad de tokens de entrada.
    /// @param amountOutMin Cantidad mínima de salida aceptable.
    /// @param path Dirección del token de entrada y salida. Debe tener longitud 2.
    /// @param to Dirección de destino para los tokens de salida.
    /// @param deadline Fecha límite para ejecutar el swap.
    /// @return amounts Array con la cantidad de entrada y la cantidad de salida.
    function swapExactTokensForTokens(
        ...
    ) external returns (uint[] memory amounts) {
        ...
    }

    /// @notice Consulta el precio relativo entre dos tokens según el pool.
    /// @param tokenA Dirección del token base.
    /// @param tokenB Dirección del token de cotización.
    /// @return price Precio de tokenA en términos de tokenB, con 18 decimales.
    function getPrice(address tokenA, address tokenB) public view returns (uint price) {
        ...
    }

    /// @notice Calcula la cantidad de salida estimada usando el producto constante.
    /// @param amountIn Monto del token de entrada.
    /// @param reserveIn Reserva actual del token de entrada.
    /// @param reserveOut Reserva actual del token de salida.
    /// @return amountOut Estimación del token de salida.
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut) {
        ...
    }
}
