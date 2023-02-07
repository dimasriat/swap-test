// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import "src/ChainlinkOracle.sol";
import "test/constants/Constants.sol";

contract ChainlinkOracleTest is Test {
    ChainlinkOracle public oracle;

    function setUp() public {
        oracle = new ChainlinkOracle(
            ETH_USD_ORACLE, // ETH / USD Chainlink Oracle
            USDC_USD_ORACLE // USDC / USD Chainlink Oracle
        );
    }

    // TODO add assertion Gt Ls
    function testETHPriceInUSD() public view {
        IAggregatorV3 ethOracle = IAggregatorV3(ETH_USD_ORACLE);
        (, int256 ethPriceInUSD, , , ) = ethOracle.latestRoundData();
        console2.log("ETH Price in USD:", ethPriceInUSD);
    }

    // TODO add assertion Gt Ls
    function testUSDCPriceInUSD() public view {
        IAggregatorV3 usdcOracle = IAggregatorV3(USDC_USD_ORACLE);
        (, int256 usdcPriceInUSD, , , ) = usdcOracle.latestRoundData();
        console2.log("USDC Price in USD:", usdcPriceInUSD);
    }

    function testGetPriceInEther() public {
        IAggregatorV3 ethOracle = IAggregatorV3(ETH_USD_ORACLE);
        (, int256 ethPriceInUSD, , , ) = ethOracle.latestRoundData();

        IAggregatorV3 usdcOracle = IAggregatorV3(USDC_USD_ORACLE);
        (, int256 usdcPriceInUSD, , , ) = usdcOracle.latestRoundData();

        uint256 price = (uint256(ethPriceInUSD) *
            10**usdcOracle.decimals() *
            1 ether) / (uint256(usdcPriceInUSD) * 10**ethOracle.decimals());

        assertEq(price, oracle.getPriceInEther());
    }
}
