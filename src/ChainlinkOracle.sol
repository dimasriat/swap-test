// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/interfaces/IAggregatorV3.sol";

contract ChainlinkOracle {
    IAggregatorV3 immutable baseFeed;
    IAggregatorV3 immutable quoteFeed;

    uint256 immutable baseDecimals;
    uint256 immutable quoteDecimals;

    constructor(
        address _baseFeed,
        address _quoteFeed,
        uint256 _baseDecimals,
        uint256 _quoteDecimals
    ) {
        baseFeed = IAggregatorV3(_baseFeed);
        quoteFeed = IAggregatorV3(_quoteFeed);

        baseDecimals = _baseDecimals;
        quoteDecimals = _quoteDecimals;
    }

    function getBaseDecimals() public view returns (uint256) {
        return baseDecimals;
    }

    function getQuoteDecimals() public view returns (uint256) {
        return quoteDecimals;
    }

    function getBasePrice() public view returns (uint256 price) {
        uint256 priceInEther = _getPriceInEther();
        price = (priceInEther * 10**getQuoteDecimals()) / 1 ether;
    }

    function getQuotePrice() public view returns (uint256 price) {
        uint256 priceInEther = (1 ether * 1 ether) / _getPriceInEther();
        price = (priceInEther * 10**getBaseDecimals()) / 1 ether;
    }

    function _getPriceInEther() private view returns (uint256) {
        (, int256 basePrice, , , ) = baseFeed.latestRoundData();
        (, int256 quotePrice, , , ) = quoteFeed.latestRoundData();

        return
            (uint256(basePrice) * 10**quoteFeed.decimals() * 1 ether) /
            (uint256(quotePrice) * 10**baseFeed.decimals());
    }
}
