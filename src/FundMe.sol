// Get funds from users
// Withdraw funds
// set minimum funding value in USD
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 795061
// 775483
error NotOwner();
error CallFailed();

contract FundMe {
    using PriceConverter for uint256;

    uint public constant MINIMUM_USD = 5 * 1e18; // immutable naming convention prefers to capitaize
    // 351 * 210000000 - execution when theres constant
    // 2451 * 210000000 - execution cost when ther's no constant

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;

    address private i_owner; // immutable naming convention prefers i_immutableName
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeedAddress) {
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
        i_owner = msg.sender;
        // 444 - immutable
        // 2580 - no immutable
    }

    function fund() public payable {
        // want to be able to set minimum amount in USD
        // 1 How do we send ETH to this contract
        // 2 How do we get the price of ETH in USD
        // 3 How do we convert ETH to USD
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough Ether"
        ); // 1e18 == 1 * 10 ** 18 == 1000000000000000000
        // 1 ETH == 1000000000000000000 wei
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (
            uint256 fundersIndex = 0;
            fundersIndex < fundersLength;
            fundersIndex++
        ) {
            address funder = s_funders[fundersIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function withdraw() public onlyOwner {
        // starting index; ending index; step amount
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset the array
        s_funders = new address[](0);

        // Actually withdraw the funds

        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // // call This is the widely used way of sending transactions
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
        // if(!callSuccess){ revert CallFailed();} - // saves gas

        // msg.sender = address
        // payable(msg.sender) = payable address
        // and when you want to send and recieve currencies to any address it has to be a payable
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not the owner");
        if (msg.sender != i_owner) {
            revert NotOwner();
        } // saves gas
        _;
    }

    // What happens when someone sends this contract ETH without calling the fund function
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * Getter Functions
     */

    /**
     * @notice Gets the amount that an address has funded
     *  @param fundingAddress the address of the funder
     *  @return the amount funded
     */
    function getAddressToAmountFunded(
        address fundingAddress
    ) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
