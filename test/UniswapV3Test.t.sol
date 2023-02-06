// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/interfaces/ISwapRouter.sol";
import "lib/forge-std/src/Test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

uint24 constant FEE_MEDIUM = 3000;

contract User {
    ISwapRouter router;

    function setRouter(ISwapRouter _router) public {
        router = _router;
    }

    function encodePath(address[] memory path, uint24[] memory fees)
        public
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
        address token0,
        address token1,
        uint256 amountETH
    ) public returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;
        uint24[] memory fees = new uint24[](path.length - 1);
        for (uint256 i = 0; i < fees.length; i++) {
            fees[i] = FEE_MEDIUM;
        }

        ISwapRouter.ExactInputParams memory params = ISwapRouter
            .ExactInputParams({
                path: encodePath(path, fees),
                recipient: address(this),
                deadline: block.timestamp + 1000,
                amountIn: amountETH,
                amountOutMinimum: 0
            });
        router.exactInput{value: amountETH}(params);
    }

    function swapToETH(
        address token0,
        address token1,
        uint256 amountToken
    ) public returns (uint256) {
        ERC20(token0).approve(address(router), amountToken);
        
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;
        uint24[] memory fees = new uint24[](path.length - 1);
        for (uint256 i = 0; i < fees.length; i++) {
            fees[i] = FEE_MEDIUM;
        }

        ISwapRouter.ExactInputParams memory params = ISwapRouter
            .ExactInputParams({
                path: encodePath(path, fees),
                recipient: address(0),
                deadline: block.timestamp + 1000,
                amountIn: amountToken,
                amountOutMinimum: 0
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

contract SwapTest is Test {
    function createUser(uint256 amount) public returns (User) {
        User user = new User();
        (bool success, ) = address(user).call{value: amount}("");
        require(success, "send eth error");
        return user;
    }

    function testMainnet() public {
        ERC20 weth = ERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
        ERC20 usdc = ERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);
        console2.log("weth name:", weth.name());
        console2.log("usdc name:", usdc.name());

        ISwapRouter router = ISwapRouter(
            0xE592427A0AEce92De3Edee1F18E0157C05861564
        );

        User user = createUser(10 ether);
        user.setRouter(router);

        console2.log("#0 user ETH balance:", address(user).balance);
        console2.log("#0 user USDC balance:", usdc.balanceOf(address(user)));

        uint256 amountOut1 = user.swapFromETH(
            address(weth),
            address(usdc),
            1 ether
        );
        console2.log("#1 amountOut:", amountOut1);
        console2.log("#1 user ETH balance:", address(user).balance);
        console2.log("#1 user USDC balance:", usdc.balanceOf(address(user)));

        uint256 amountOut2 = user.swapToETH(
            address(usdc),
            address(weth),
            usdc.balanceOf(address(user))
        );
        console2.log("#2 user ETH balance:", address(user).balance);
        console2.log("#2 user USDC balance:", usdc.balanceOf(address(user)));
    }
}
