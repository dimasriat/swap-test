// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ChainlinkSwap {
    event Call(address sender, string message);

    function callMessage(string memory message) public {
        emit Call(msg.sender, message);
    }
}
