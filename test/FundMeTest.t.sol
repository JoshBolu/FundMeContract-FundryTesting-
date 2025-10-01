// SPDX-License-Identifier:MIT SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("joshua");
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() public {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        // deal is a function that sets the balance of an address
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        // we can't use msg.sender in tests because the test contract is the one that deploys the FundMe contract so the owner will be the test contract address instead we use address(this), but when we're working with rpc-url msg.sender is now equal to fundMe.i_owner()
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        console.log(fundMe.getVersion());
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailWithoutEnoughEth() public {
        vm.expectRevert(); // It is saying the next line must revert
        // uint256 passedRevert = 2; // This test will fail because the code didn't fail we need to do something that fails to pass the test
        // fundMe.fund{value: 1400000000000000}(); // passed in 0.0014ETH == $6.03(4307) but the minimum is $5 because the right consitions are met the test would fail
        fundMe.fund{value: 14000000000000}(); // passed in 0.000014ETH == $0.06(4307) so the test would pass because test expects to fail if minimum USD isn't sent
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // The next tx will be sent by address(1)
        // fundMe.fund{value: 1e18}();
        // uint256 amountFunded = fundMe.s_addressToAmountFunded(address(1));
        // assertEq(amountFunded, 1e18);

        fundMe.fund{value: 10 ether}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, 10 ether);
    }
}
