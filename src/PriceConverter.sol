// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// libraries can't have any state varaibles and can't send transaction(Ether) and all the function are going to be internal
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // ABI
        // Address  0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43 BTC/USD
        // 0x694AA1769357215DE4FAC081bf1f309aDC325306 ETH/USD
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // ETH in terms of USD
        // 3000.00000000
        return uint256(price * 1e10); // 1**10 == 10000000000
    }

    function getVersionDecimal() internal view returns (uint256, uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        return (priceFeed.version(), priceFeed.decimals());
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed); // 1 ETH == 3000 USD
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; // since both ethPrice and ethAmount both have 18 decimal places if we multiply them without the 1e18 division the result will produce 36 decimal places
        return ethAmountInUsd;
    }
}
