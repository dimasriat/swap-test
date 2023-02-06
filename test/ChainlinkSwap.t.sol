// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import "src/ChainlinkSwap.sol";

contract User {
    ChainlinkSwap swap;
    constructor(ChainlinkSwap _swap) {
        swap = _swap;
    }
    function callMessage(string memory message) public {
        swap.callMessage(message);
    }
}

contract ChainlinkSwapTest is Test {
    ChainlinkSwap public swap;

    function setUp() public {
        swap = new ChainlinkSwap();
    }

    function testCall() public {
        swap.callMessage("hi bro");
        
        User alice = new User(swap);
        alice.callMessage("alice was here");
        console.log(address(alice));
    }
}
