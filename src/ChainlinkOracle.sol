// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/interfaces/IAggregatorV3.sol";

contract ChainlinkOracle {
    IAggregatorV3 baseFeed;
    IAggregatorV3 quoteFeed;

    constructor(address _baseFeed, address _quoteFeed) {
        baseFeed = IAggregatorV3(_baseFeed);
        quoteFeed = IAggregatorV3(_quoteFeed);
    }

    function getPriceInEther() public view returns (uint256) {
        (, int256 basePrice, , , ) = baseFeed.latestRoundData();
        (, int256 quotePrice, , , ) = quoteFeed.latestRoundData();

        return
            (uint256(basePrice) * 10**quoteFeed.decimals() * 1 ether) /
            (uint256(quotePrice) * 10**baseFeed.decimals());
    }
}
