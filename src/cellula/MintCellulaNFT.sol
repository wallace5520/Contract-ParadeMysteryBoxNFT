// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../metadata/IMetadataRenderer.sol";

contract MintCellulaNFT is
    Initializable,
    ERC721Upgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    using Strings for uint256;
    uint256 private _nextTokenId;

    mapping(address => uint256) public allClaimedNumbers;
    mapping(address => uint256) public alreadyClaimedNumbers;

    address public metadataRenderer;

    uint256 public constant MAX_NUMBERS = 12000;

    event AddWhitelist(address[] _addresses);
    event MintBatch(address indexed to, uint256 numbers);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __ERC721_init("Mint_Cellula_NFT", "Cellula");
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    function mint() internal {
        address minter = msg.sender;
        uint256 _maxClaimed = maxClaimed(minter);
        uint256 _alreadyClaimed = alreadyClaimed(minter);
        require(_maxClaimed > _alreadyClaimed, "No Mintable NFT");

        uint256 mintIndex = _nextTokenId++;
        // _mint(minter, tokenId);

        // uint mintIndex = totalSupply() + 1;
        if (mintIndex <= MAX_NUMBERS) {
            _safeMint(minter, mintIndex);
        }

        alreadyClaimedNumbers[minter]++;
    }

    function mintBatch(uint256 numbers) external {
        require(numbers > 0, "The Claim numbers must more than 0 ");
        for (uint256 i = 0; i < numbers; ) {
            mint();
            unchecked {
                ++i;
            }
        }
        emit MintBatch(msg.sender, numbers);
    }

    function addWhitelist(address[] calldata _addresses) external onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            allClaimedNumbers[_addresses[i]]++;
        }
        emit AddWhitelist(_addresses);
    }
    function maxClaimed(address owner) public view returns (uint256) {
        return allClaimedNumbers[owner];
    }
    function alreadyClaimed(address owner) public view returns (uint256) {
        return alreadyClaimedNumbers[owner];
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
