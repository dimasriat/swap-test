// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/interfaces/IAggregatorV3.sol";

contract ChainlinkOracle {
    IAggregatorV3 immutable baseFeed;
    IAggregatorV3 immutable quoteFeed;

    constructor(address _baseFeed, address _quoteFeed) {
        baseFeed = IAggregatorV3(_baseFeed);
        quoteFeed = IAggregatorV3(_quoteFeed);
    }

    function getBasePriceInEther() public view returns (uint256 price) {
        price = getPriceInEther();
    }

    function getQuotePriceInEther() public view returns (uint256 price) {
        price = (1 ether * 1 ether) / getPriceInEther();
    }

    function getPriceInEther() private view returns (uint256) {
        (, int256 basePrice, , , ) = baseFeed.latestRoundData();
        (, int256 quotePrice, , , ) = quoteFeed.latestRoundData();

        return
            (uint256(basePrice) * 10**quoteFeed.decimals() * 1 ether) /
            (uint256(quotePrice) * 10**baseFeed.decimals());
    }
}
