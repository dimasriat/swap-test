// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/UniswapV3.sol";

contract ChainlinkSwap {
    UniswapV3 swap;
    ChainlinkOracle oracle;
    address WETH;

    constructor(
        UniswapV3 _swap,
        ChainlinkOracle _oracle,
        address _WETH
    ) {
        swap = _swap;
        oracle = _oracle;
        WETH = _WETH;
    }

    // TODO add slippage checker
    function swapFromETH(address tokenOut) {
        swap.swapFromETH(WETH, tokenOut, msg.value, 0);
    }

    // TODO add slippage checker
    function swapToETH(address tokenIn, uint256 amountIn) {
        swap.swapToETH(tokenIn, WETH, amountIn, 0);
    }
}
