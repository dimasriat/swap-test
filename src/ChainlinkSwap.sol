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
        address _quoteFeed,
        uint256 _baseDecimals,
        uint256 _quoteDecimals
    ) ChainlinkOracle(_baseFeed, _quoteFeed, _baseDecimals, _quoteDecimals) {
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
        uint256 amountOutMinBeforeSlippage;
        uint256 amountOutMin;

        if (tokenIn == address(quoteToken) && tokenOut == address(baseToken)) {
            // amountIn is USDC (10**6)

            // price is WETH (10**18)
            price = getQuotePrice();

            // amountOutMinBeforeSlippage is WETH (10**18)
            amountOutMinBeforeSlippage =
                (price * amountIn) /
                10**getQuoteDecimals();
        } else if (
            tokenIn == address(baseToken) && tokenOut == address(quoteToken)
        ) {
            // amountIn is WETH (10**18)

            // price is USDC (10**6)
            price = getBasePrice();

            // amountOutMinBeforeSlippage is USDC (10**6)
            amountOutMinBeforeSlippage =
                (price * amountIn) /
                10**getBaseDecimals();
        } else {
            revert(
                "both tokenIn and tokenOut must be either quote and base or vice versa!"
            );
        }

        amountOutMin =
            amountOutMinBeforeSlippage -
            (0.01 ether * amountOutMinBeforeSlippage) /
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
