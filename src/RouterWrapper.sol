// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/interfaces/ISwapRouter.sol";
import "lib/forge-std/src/Test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract RouterWrapper {
    ISwapRouter router;

    constructor(ISwapRouter _router) {
        router = _router;
    }

    function encodePath(address[] memory path, uint24[] memory fees)
        private
        pure
        returns (bytes memory)
    {
        bytes memory res;
        for (uint256 i = 0; i < fees.length; i++) {
            res = abi.encodePacked(res, path[i], fees[i]);
        }
        res = abi.encodePacked(res, path[path.length - 1]);
        return res;
    }

    function swapFromETH(
        address weth,
        address token,
        uint256 amountOutMin
    ) public payable {
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = token;

        uint24[] memory fees = new uint24[](path.length - 1);
        fees[0] = 3000; // FEE_MEDIUM

        ISwapRouter.ExactInputParams memory params = ISwapRouter
            .ExactInputParams({
                path: encodePath(path, fees),
                recipient: address(this),
                deadline: block.timestamp + 1000,
                amountIn: msg.value,
                amountOutMinimum: amountOutMin
            });
        router.exactInput{value: msg.value}(params);
    }

    function swapToETH(
        address token,
        address weth,
        uint256 amountToken,
        uint256 amountOutMin
    ) public {
        ERC20(token).approve(address(router), amountToken);

        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = weth;

        uint24[] memory fees = new uint24[](path.length - 1);
        fees[0] = 3000; // FEE_MEDIUM

        ISwapRouter.ExactInputParams memory params = ISwapRouter
            .ExactInputParams({
                path: encodePath(path, fees),
                recipient: address(0),
                deadline: block.timestamp + 1000,
                amountIn: amountToken,
                amountOutMinimum: amountOutMin
            });

        bytes[] memory data;
        bytes memory inputs = abi.encodeWithSelector(
            router.exactInput.selector,
            params
        );

        data = new bytes[](2);
        data[0] = inputs;
        data[1] = abi.encodeWithSelector(
            router.unwrapWETH9.selector,
            0,
            address(this)
        );

        router.multicall(data);
    }

    receive() external payable {}
}
