// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelpConfig} from "./HelpConfig.s.sol";

contract DeployFundMe is Script{

// Before the startbroadcast is not a real transaction
    HelpConfig helpConfig = new HelpConfig();

    address ethUsdPriceFeed= helpConfig.activeNetworkConfig();
    // After startbroadcast is a real transaction

    FundMe fundMe;

    function run() external  returns (FundMe){
        vm.startBroadcast();
    
        FundMe fundMe = new FundMe(ethUsdPriceFeed);

        vm.stopBroadcast();
        return fundMe;
    }

}