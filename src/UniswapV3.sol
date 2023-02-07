// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/interfaces/ISwapRouter.sol";
import "lib/forge-std/src/Test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract UniswapV3 {
    ISwapRouter routerV3;

    function setRouterV3(ISwapRouter _routerV3) public {
        routerV3 = _routerV3;
    }

    function encodePath(address[] memory path, uint24[] memory fees)
        private
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
        address token1,
        uint256 amountETH,
        uint256 amountOutMin
    ) public returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = token1;

        uint24[] memory fees = new uint24[](path.length - 1);
        fees[0] = FEE_MEDIUM;

        ISwapRouter.ExactInputParams memory params = ISwapRouter
            .ExactInputParams({
                path: encodePath(path, fees),
                recipient: address(this),
                deadline: block.timestamp + 1000,
                amountIn: amountETH,
                amountOutMinimum: amountOutMin
            });
        routerV3.exactInput{value: amountETH}(params);
    }

    function swapToETH(
        address token0,
        address weth,
        uint256 amountToken,
        uint256 amountOutMin
    ) public returns (uint256) {
        ERC20(token0).approve(address(routerV3), amountToken);

        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = weth;

        uint24[] memory fees = new uint24[](path.length - 1);
        fees[0] = FEE_MEDIUM;

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
            routerV3.exactInput.selector,
            params
        );

        data = new bytes[](2);
        data[0] = inputs;
        data[1] = abi.encodeWithSelector(
            routerV3.unwrapWETH9.selector,
            0,
            address(this)
        );

        routerV3.multicall(data);
    }

    receive() external payable {}
}
