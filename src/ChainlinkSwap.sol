// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "src/interfaces/ISwapRouter.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "src/ChainlinkOracle.sol";

contract ChainlinkSwap is ChainlinkOracle {
    ISwapRouter constant router =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    IERC20 immutable baseToken;
    IERC20 immutable quoteToken;

    constructor(
        address _baseToken,
        address _quoteToken,
        address _baseFeed,
        address _quoteFeed
    ) ChainlinkOracle(_baseFeed, _quoteFeed) {
        baseToken = IERC20(_baseToken);
        quoteToken = IERC20(_quoteToken);
    }

    function swapExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 poolFee,
        uint256 amountIn
    ) public returns (uint256 amountOut) {
        uint256 price;

        if (tokenIn == address(quoteToken) && tokenOut == address(baseToken)) {
            // input is USDC
            price = getQuotePriceInEther();
        } else if (
            tokenIn == address(baseToken) && tokenOut == address(quoteToken)
        ) {
            // input is WETH
            price = getBasePriceInEther();
        } else {
            revert(
                "both tokenIn and tokenOut must be either quote and base or vice versa!"
            );
        }

        uint256 amountOutMinBeforeSlippage = (price * amountIn) / 1 ether;
        uint256 amountOutMin = amountOutMinBeforeSlippage -
            (amountOutMinBeforeSlippage * 0.01 ether) /
            1 ether;

        amountOut = _swapExactInputSingle(
            tokenIn,
            tokenOut,
            poolFee,
            amountIn,
            amountOutMin
        );
    }

    function _swapExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 poolFee,
        uint256 amountIn,
        uint256 amountOutMinimum
    ) private returns (uint256 amountOut) {
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(address(router), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: amountOutMinimum,
                sqrtPriceLimitX96: 0
            });

        amountOut = router.exactInputSingle(params);
    }
}
