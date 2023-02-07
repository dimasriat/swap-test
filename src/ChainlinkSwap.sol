// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/RouterWrapper.sol";
import "src/ChainlinkOracle.sol";

address constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

contract ChainlinkSwap {
    RouterWrapper routerWrapper;
    ChainlinkOracle oracle;

    constructor(RouterWrapper _routerWrapper, ChainlinkOracle _oracle) {
        routerWrapper = _routerWrapper;
        oracle = _oracle;
    }

    function swapFromETH(address tokenOut) public payable {
        uint256 amountOutMin = 0;

        routerWrapper.swapFromETH{value: msg.value}(
            WETH,
            tokenOut,
            amountOutMin
        );
    }

    function swapToETH(address tokenIn, uint256 amountIn) public {
		uint256 amountOutMin = 0;

        routerWrapper.swapToETH(
			tokenIn,
            WETH,
			amountIn,
            amountOutMin
        );
	}

    receive() external payable {}
}
