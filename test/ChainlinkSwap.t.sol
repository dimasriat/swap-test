// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import "src/ChainlinkSwap.sol";
import "src/interfaces/AggregatorV3Interface.sol";

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
        console2.log("Alice's address:", address(alice));
    }

    function testETHPriceInUSD() public view {
        AggregatorV3Interface ethOracle = AggregatorV3Interface(
            0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612
        );
        (, int256 ethPriceInUSD, , , ) = ethOracle.latestRoundData();
        console2.log("ETH Price in USD:", ethPriceInUSD);
    }

    function testUSDCPriceInUSD() public view {
        AggregatorV3Interface usdcOracle = AggregatorV3Interface(
            0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3
        );
        (, int256 usdcPriceInUSD, , , ) = usdcOracle.latestRoundData();
        console2.log("USDC Price in USD:", usdcPriceInUSD);
    }
}
