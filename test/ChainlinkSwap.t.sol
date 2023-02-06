// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import "src/ChainlinkSwap.sol";

contract ChainlinkSwapTest is Test {
    ChainlinkSwap public swap;

    function setUp() public {
        swap = new ChainlinkSwap();
    }

    function testCall() public {
        swap.callMessage("hi bro");
    }
}
