// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import "src/ChainlinkOracle.sol";

contract ChainlinkOracleTest is Test {
    ChainlinkOracle public oracle;

    function setUp() public {
        oracle = new ChainlinkOracle(
            0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612, // ETH / USD Chainlink Oracle
            0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3 // USDC / USD Chainlink Oracle
        );
    }

    function testGetPriceInEther() public {
        IAggregatorV3 ethOracle = IAggregatorV3(
            0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612
        );
        (, int256 ethPriceInUSD, , , ) = ethOracle.latestRoundData();

        IAggregatorV3 usdcOracle = IAggregatorV3(
            0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3
        );
        (, int256 usdcPriceInUSD, , , ) = usdcOracle.latestRoundData();

        uint256 price = (uint256(ethPriceInUSD) *
            10**usdcOracle.decimals() *
            1 ether) / (uint256(usdcPriceInUSD) * 10**ethOracle.decimals());

        assertEq(price, oracle.getPriceInEther());
    }
}
