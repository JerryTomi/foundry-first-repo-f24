// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {


    FundMe fundMe;


    address USER =makeAddr ("user");

    uint256 constant SEND_VALUE =0.1 ether;//declaration variable constant
    uint256 constant STARTING_BALANCE =10 ether;
    uint256 constant GAS_PRICE=1;

    function setUp()  external {
        // fundMe=new FundMe();
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe =deployFundMe.run();

        vm.deal (USER, STARTING_BALANCE);
    }
    function testMinimumDollar() public view{
       assertEq (fundMe.MINIMUM_USD(), 5e18);
        
    }

    function testOwnerisMsgSender()public view {
        assertEq(fundMe.getOwner(), msg.sender);
        

    }
    
   function testPriceFeedVersionIsAccurate() public view {
         uint256 version= fundMe.getVersion();
         assertEq(version, 4);

   }
   
   function testFundMeFailsWitoutEnoughEth() public view {

    vm.expectRevert (); 
    // aasert(This tx fails/reverts)

    fundMe.fund();// no value is here
   }

   function testFundUpdatesFunderDataStructure() public {

    vm.prank(USER); // THEtx here is sent by the "USER"

    fundMe.fund{value: SEND_VALUE}();

    uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
    assertEq(amountFunded, SEND_VALUE);

    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank (USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);

        assertEq(funder, USER);
    }

    modifier funded (){
         vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;


    }

    function testOnlyOwnerCanWithdraw() public funded {
    

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithedrawWithASingleFunder() public funded {

        // Arrange
        uint256 startingOwnerBalance= fundMe.getOwner().balance;
        uint256 startingFundMeBalance= address(fundMe).balance;

        // Act
        uint256 gasStart= gasleft();// 1000 = gas maximum
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());// costs =200
        fundMe.withdraw();

        uint256 gasEnd =gasleft();// 800 = gas remaining
        uint256 gasUsed =(gasStart-gasEnd) *tx.gasPrice;


        // Assert
        uint256 endingOwnerBalance= fundMe.getOwner().balance;
        uint256 endingFundMeBalance= address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);

    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders=10;
        uint160 startingFundersIndex =2;
        for (uint160 i = startingFundersIndex; i< numberofFunders; i++){
            // vm.prank new address
            // vm.deal new address
            // address()
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            // fund the value

            // Act 
            vm.startPrank(fundMe.getOwner());
            fundMe.withdraw();
            vm.stopPrank(); 

            // Assert
            assert(address(fundMe).balance == 0);
            assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);

        }

    // function testOnlyOwnerCanWithdraw() public funded {
    

    //     vm.expectRevert();
    //     vm.prank(USER);
    //     fundMe.withdrawCheaper();
    }

    function testWithedrawWithASingleFunder() public funded {

        // Arrange
        uint256 startingOwnerBalance= fundMe.getOwner().balance;
        uint256 startingFundMeBalance= address(fundMe).balance;

        // Act
        uint256 gasStart= gasleft();// 1000 = gas maximum
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());// costs =200
        fundMe.withdraw();

        uint256 gasEnd =gasleft();// 800 = gas remaining
        uint256 gasUsed =(gasStart-gasEnd) *tx.gasPrice;


        // Assert
        uint256 endingOwnerBalance= fundMe.getOwner().balance;
        uint256 endingFundMeBalance= address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);

    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders=10;
        uint160 startingFundersIndex =2;
        for (uint160 i = startingFundersIndex; i< numberofFunders; i++){
            // vm.prank new address
            // vm.deal new address
            // address()
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            // fund the value

            // Act 
            vm.startPrank(fundMe.getOwner());
            fundMe.cheaperWithdraw();
            vm.stopPrank(); 

            // Assert
            assert(address(fundMe).balance == 0);
            assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);



        }
    }


}