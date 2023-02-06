// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ISwapRouter {
    function unwrapWETH9(uint256 amountMinimum, address recipient)
        external
        payable;

    function multicall(bytes[] calldata data)
        external
        payable
        returns (bytes[] memory results);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params)
        external
        payable
        returns (uint256 amountOut);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(ExactOutputParams calldata params)
        external
        payable
        returns (uint256 amountIn);
}
