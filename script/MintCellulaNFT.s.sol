// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";
import "forge-std/Script.sol";
import "../src/cellula/MintCellulaNFT.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract MintCellulaNFTUUPS is Script {

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address owner = vm.envAddress("OWNER");

        address uupsProxy = Upgrades.deployUUPSProxy(
            "MintCellulaNFT.sol",
            abi.encodeCall(MintCellulaNFT.initialize, owner)
        );

        console.log("uupsProxy deploy at %s", uupsProxy);

        // contract upgrade
        // Upgrades.upgradeProxy(
        //     0x57aA394Cd408c1dB3E0De979e649e82BF8dD395F,
        //     "MintSwap404NFT.sol",
        //     ""
        // );

        vm.stopBroadcast();
    }
    
}