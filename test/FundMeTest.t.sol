// SPDX-License-Identifier:MIT SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("joshua");
    uint256 constant STARTING_BALANCE = 10 ether;

    uint256 constant SEND_ETHER = 1 ether;
    uint256 constant GAS_PRICE = 1;

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
        vm.prank(USER); // The next tx will be sent by USER
        // fundMe.fund{value: 1e18}();
        // uint256 amountFunded = fundMe.s_addressToAmountFunded(address(1));
        // assertEq(amountFunded, 1e18);

        fundMe.fund{value: SEND_ETHER}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_ETHER);
    }

    function testAddOwnerToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_ETHER}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_ETHER}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        // uint256 gasStart = gasleft(); // 1000
        // vm.txGasPrice(GAS_PRICE); // 200

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // uint256 gasEnd = gasleft(); // 800
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log(tx.gasprice);
        // console.log(gasStart);
        // console.log(gasEnd);
        // console.log(gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        // we use uint160 because that the way we can convert it to address
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank(address(i)); to create an address from a number
            // deal(address(i), SEND_ETHER); to send ether to that address
            // we can use hoax to do both of the above in one line
            hoax(address(i), SEND_ETHER);
            // fund the fundMe contract from that address
            fundMe.fund{value: SEND_ETHER}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        // verify that the fundMe contract balance was withdrawn
        assertEq(address(fundMe).balance, 0);
        // verify that the owner received the funds by adding his Ether balance with what he just recieved
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            fundMe.getOwner().balance
        );
    }
}
