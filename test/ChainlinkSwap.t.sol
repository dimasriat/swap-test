// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import "src/ChainlinkSwap.sol";
import "src/interfaces/IWETH.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "test/constants/Constants.sol";

contract ChainlinkSwapTest is Test {
    IWETH private weth = IWETH(WETH);
    IERC20 private usdc = IERC20(USDC);

    ChainlinkSwap private swap;

    function setUp() public {
        swap = new ChainlinkSwap(
            WETH,
            USDC,
            ETH_USD_ORACLE,
            USDC_USD_ORACLE,
            WETH_DECIMALS,
            USDC_DECIMALS
        );
    }

    function testSwapFromETH() public {
        uint256 balanceBefore = address(this).balance;
        uint256 amountETH = 1 ether;

        // Wrap ETH before Swap
        weth.deposit{value: amountETH}();

        // weth balance must be increased
        assertEq(
            weth.balanceOf(address(this)),
            balanceBefore - address(this).balance
        );

        weth.approve(address(swap), amountETH);

        // Swap ETH to USDC, amountOut must be the USDC we got
        uint256 amountOut = swap.swapExactInputSingle(
            WETH,
            USDC,
            3000,
            amountETH
        );

        // weth balance must be zero
        assertEq(weth.balanceOf(address(this)), 0);

        // usdc balance must be the same value as the amountOut
        assertEq(usdc.balanceOf(address(this)), amountOut);
    }

    function testSwapToETH() public {
        weth.deposit{value: 1 ether}();
        weth.approve(address(swap), 1 ether);

        uint256 amountOutUSDC = swap.swapExactInputSingle(
            WETH,
            USDC,
            3000,
            1 ether
        );

        console.log("USDC", amountOutUSDC);

        usdc.approve(address(swap), amountOutUSDC);
        uint256 amountOutETH = swap.swapExactInputSingle(
            USDC,
            WETH,
            3000,
            amountOutUSDC
        );

        console.log("ETH", amountOutETH);
        console.log("WETH Balance", weth.balanceOf(address(this)));
    }
}
