// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../metadata/IMetadataRenderer.sol";

contract ParadeMysteryBoxNFT is
    Initializable,
    ERC721Upgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    uint256 private _nextTokenId;

    mapping(address => uint256) public allClaimedAmounts;
    mapping(address => uint256) public alreadyClaimedAmounts;

    address public metadataRenderer;

    uint256 public constant MAX_AMOUNTS = 12000;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __ERC721_init("Parade Mystery Box", "PMB");
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    function mint(address minter) internal {
        uint256 mintIndex = ++_nextTokenId;
        _mint(minter, mintIndex);

        alreadyClaimedAmounts[minter]++;
    }

    function mintBatch(uint256 amounts) external {
        require(amounts > 0, "Invalid Amounts: Must More Than 0 ");
        require(
            amounts + _nextTokenId <= MAX_AMOUNTS,
            "Invalid Amounts: More Than MAX_NUMBERS"
        );

        address _minter = _msgSender();
        uint256 _maxClaimed = allClaimedAmounts[_minter];
        uint256 _alreadyClaimed = alreadyClaimedAmounts[_minter];
        require(
            _maxClaimed - _alreadyClaimed >= amounts,
            "Invalid Amounts: Out Of Address Mint Range"
        );

        for (uint256 i = 0; i < amounts; ) {
            mint(_minter);
            unchecked {
                ++i;
            }
        }
    }

    function addWhitelist(address[] calldata _addresses) external onlyOwner {
        require(_addresses.length > 0, "The address amounts must more than 0 ");

        for (uint i = 0; i < _addresses.length; i++) {
            allClaimedAmounts[_addresses[i]]++;
        }
    }



    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(ownerOf(tokenId) != address(0), "Invalid tokenId");
        return IMetadataRenderer(metadataRenderer).tokenURI(tokenId);
    }

    function setMetadataRenderer(address _metadataRenderer) public onlyOwner {
        metadataRenderer = _metadataRenderer;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
