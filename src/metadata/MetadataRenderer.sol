// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "./IMetadataRenderer.sol";

contract MetadataRenderer is IMetadataRenderer, Ownable {
    string private imageURI;
    string private name;
    string private description;

    constructor(
        string memory _defaultName,
        string memory _description,
        string memory _defaultImageURI
    ) Ownable(_msgSender()) {
        name = _defaultName;
        description = _description;
        imageURI = _defaultImageURI;
    }

    function tokenURI(
        uint256 tokenID
    ) external view override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(bytes(tokenURIJSON(tokenID)))
                )
            );
    }

    function tokenURIJSON(uint256 tokenID) public view returns (string memory) {
        uint256 _mp = 0;
        string memory _mp_level_img;
        (_mp,_mp_level_img) = getMp(tokenID);

        return
            string(
                abi.encodePacked(
                    "{",
                    '"name": "',
                    name,
                    " #",
                    Strings.toString(tokenID),
                    '",',
                    '"description": "',
                    description,
                    '",',
                    '"MP": "',
                    Strings.toString(_mp),
                    '",',
                    '"image": "',
                    string.concat(imageURI, _mp_level_img),
                    ".png",
                    '"}'
                )
            );
    }

    function setName(string calldata _newName) external onlyOwner {
        name = _newName;
    }

    function setImageUri(string calldata _newURI) external onlyOwner {
        imageURI = _newURI;
    }

    function setDescription(string calldata _description) external onlyOwner {
        description = _description;
    }

    function getMp(uint256 tokenID) internal pure returns (uint256,string memory) {
        uint256 _seed;
        (, _seed) = Math.tryMod(tokenID, 10);
        uint256 mp = 0;
        string memory mp_level_img;
        if (_seed == 1 || _seed == 4 || _seed == 7 || _seed == 9) {
            mp = 150;
            mp_level_img = "3";
        } else if (_seed == 2 || _seed == 5) {
            mp = 100;
            mp_level_img = "2";
        } else if (_seed == 3 || _seed == 6) {
            mp = 200;
            mp_level_img = "4";
        } else if (_seed == 8) {
            mp = 50;
            mp_level_img = "1";
        } else if (_seed == 0) {
            mp = 250;
            mp_level_img = "5";
        }

        return (mp,mp_level_img);
    }
}
