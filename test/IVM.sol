// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IVM {
    function addr(uint256 sk) external returns (address);
    function warp(uint256 x) external;
    function roll(uint256 x) external;
    function store(address c, bytes32 loc, bytes32 val) external;
    function expectRevert(bytes calldata) external;
    function startPrank(address sender) external;
    function prank(address sender) external;
    function stopPrank() external;
}

