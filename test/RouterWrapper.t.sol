// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/interfaces/ISwapRouter.sol";
import "lib/forge-std/src/Test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "src/RouterWrapper.sol";

contract RouterWrapperTest is
    Test,
    RouterWrapper(ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564))
{
    ERC20 weth;
    ERC20 usdc;

    function setUp() public {
        weth = ERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
        usdc = ERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);
    }

    function testSwapFromETH() public {
        uint256 ethBalanceBefore = address(this).balance;
        uint256 usdcBalanceBefore = usdc.balanceOf(address(this));

        swapFromETH(address(weth), address(usdc), 1 ether, 0);

        uint256 ethBalanceAfter = address(this).balance;
        uint256 usdcBalanceAfter = usdc.balanceOf(address(this));

        assertLt(ethBalanceAfter, ethBalanceBefore);
        assertGt(usdcBalanceAfter, usdcBalanceBefore);
    }

    function testFailSwapFromETHIfSlippageIsHigh() public {
        swapFromETH(address(weth), address(usdc), 1 ether, 1700 * 1e6);
    }

    function testSwapfromUSDCBackToETH() public {
        uint256 ethBalanceBefore = address(this).balance;
        uint256 usdcBalanceBefore = usdc.balanceOf(address(this));

        swapFromETH(address(weth), address(usdc), 1 ether, 0);

        uint256 ethBalanceAfter = address(this).balance;
        uint256 usdcBalanceAfter = usdc.balanceOf(address(this));

        assertLt(ethBalanceAfter, ethBalanceBefore);
        assertGt(usdcBalanceAfter, usdcBalanceBefore);

        swapToETH(
            address(usdc),
            address(weth),
            usdc.balanceOf(address(this)),
            0
        );

        uint256 ethBalanceAfter2 = address(this).balance;
        uint256 usdcBalanceAfter2 = usdc.balanceOf(address(this));

        assertGt(ethBalanceAfter2, ethBalanceAfter);
        assertLt(usdcBalanceAfter2, usdcBalanceAfter);
    }

    function testFailSwapfromUSDCBackToETHIfSlippageHigh() public {
        swapFromETH(address(weth), address(usdc), 1 ether, 0);

        swapToETH(
            address(usdc),
            address(weth),
            usdc.balanceOf(address(this)),
            1 ether
        );
    }
}
