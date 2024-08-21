// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/cellula/MintCellulaNFT.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract TestMintCellulaNFT is Test {
    address constant SENDER_ADDRESS =
        0x42e8bA50cA28e2B5557F909185ec5ad50f82675e;
    address constant SOME_ADDRESS = 0x21cB920Bf98041CD33A68F7543114a98e420Da0B;
    address constant OWNER_ADDRESS = 0xb84C357F5F6BB7f36632623105F10cFAD3DA18A6;

    address private proxy;
    MintCellulaNFT private instance;

    function setUp() public {
        console.log("=======setUp============");
        proxy = Upgrades.deployUUPSProxy(
            "MintCellulaNFT.sol",
            abi.encodeCall(MintCellulaNFT.initialize, OWNER_ADDRESS)
        );

        console.log("uups proxy -> %s", proxy);

        instance = MintCellulaNFT(proxy);
        assertEq(instance.owner(), OWNER_ADDRESS);

        address implAddressV1 = Upgrades.getImplementationAddress(proxy);

        console.log("impl proxy -> %s", implAddressV1);
    }

    function testMint() public {
        // =========================publicSale=============================
        console.log("testMint");
        // vm.prank(OWNER_ADDRESS);
        vm.startPrank(OWNER_ADDRESS);

        console.log("----- addWhitelist -----");
        address[] memory _addresses = new address[](4);
        _addresses[0] = address(0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9);
        _addresses[1] = address(0xC565FC29F6df239Fe3848dB82656F2502286E97d);
        _addresses[2] = address(0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9);
        _addresses[3] = address(0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9);
        instance.addWhitelist(_addresses);
        vm.stopPrank();

        vm.startPrank(0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9);
        console.log("----- all -----");
        assertEq(
            instance.maxClaimed(0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9),
            3
        );
        assertEq(
            instance.alreadyClaimed(0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9),
            0
        );
        instance.mintBatch(1);
        console.log("----- mintBatch 1 -----");
        assertEq(
            instance.maxClaimed(0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9),
            3
        );
        assertEq(
            instance.alreadyClaimed(0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9),
            1
        );
        instance.mintBatch(2);
        console.log("----- mintBatch 2 all -----");
        assertEq(
            instance.maxClaimed(0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9),
            3
        );
        assertEq(
            instance.alreadyClaimed(0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9),
            3
        );
        vm.stopPrank();

        vm.startPrank(OWNER_ADDRESS);
        address[] memory _addresses2 = new address[](4);
        _addresses2[0] = address(0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9);
        _addresses2[1] = address(0xC565FC29F6df239Fe3848dB82656F2502286E97d);
        _addresses2[2] = address(0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9);
        _addresses2[3] = address(0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9);

        instance.addWhitelist(_addresses);

        assertEq(
            instance.maxClaimed(0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9),
            6
        );
        assertEq(
            instance.alreadyClaimed(0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9),
            3
        );

        assertEq(
            instance.maxClaimed(0xC565FC29F6df239Fe3848dB82656F2502286E97d),
            2
        );
        assertEq(
            instance.alreadyClaimed(0xC565FC29F6df239Fe3848dB82656F2502286E97d),
            0
        );
        vm.stopPrank();

        vm.startPrank(0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9);
        string memory tokenUri2 = instance.tokenURI(1);
        console.log("----- tokenUri2 1 -----", tokenUri2);
        vm.stopPrank();
    }
}
