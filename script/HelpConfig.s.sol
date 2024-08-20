// SPDX-License-Identifier: MIT

// Deploy mocks when we aree on a local anvil
// keep track of different mocks for different networks and addresses
// SEPOLIA ETH/USD
// MAINNET ETH/USD

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.s.sol";

contract HelpConfig  is Script{
    // On local anvil, we deploy mocks 
    // On live networks, we deploy the actual contracts and grab the exoisting address from them
    // This is an example of a contract that can be deployed on live networks

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS=8;
    int public constant INITIAL_PRICE=2000e8;


    struct NetworkConfig {
        address priceFeed; //ETH/USD price feed ADDRESS
    }

    constructor () {
        if (block.chainid == 11155111){
            activeNetworkConfig = getSepoliaETHConfig();
        } else if (block.chainid == 1){
            activeNetworkConfig = getMainnetETHConfig();
        }
        else {
            activeNetworkConfig = getOrCreateAnvilETHConfig();
            }
        
    }
    
    function getSepoliaETHConfig()public pure returns (NetworkConfig memory) {

        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});

        return sepoliaConfig;

        // price feed address

    }

    function getMainnetETHConfig()public pure returns (NetworkConfig memory){
        NetworkConfig memory mainnetConfig = NetworkConfig({priceFeed:0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});

        return mainnetConfig;
    }

    function getOrCreateAnvilETHConfig ()public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }
        // price feed address

        // deploy mocks
        // return a mock address

        vm.startBroadcast();

        MockV3Aggregator mockPriceFeed = new MockV3Aggregator( 
            DECIMALS, 
            INITIAL_PRICE
        );

        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
      
}

}