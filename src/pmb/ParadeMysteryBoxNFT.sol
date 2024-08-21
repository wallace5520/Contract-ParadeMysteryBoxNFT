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
    using Strings for uint256;
    uint256 private _nextTokenId;

    mapping(address => uint256) public allClaimedAmounts;
    mapping(address => uint256) public alreadyClaimedAmounts;

    address public metadataRenderer;

    uint256 public constant MAX_AMOUNTS = 12000;

    event AddWhitelist(address[] _addresses);
    event MintBatch(address indexed to, uint256 numbers);

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
        if (mintIndex <= MAX_AMOUNTS) {
            _mint(minter, mintIndex);
        }

        alreadyClaimedAmounts[minter]++;
    }

    function mintBatch(uint256 amounts) external {
        require(amounts > 0, "Invalid Amounts: Must More Than 0 ");
        require(
            amounts + _nextTokenId <= MAX_AMOUNTS,
            "Invalid Amounts: More Than MAX_NUMBERS"
        );

        address _minter = _msgSender();
        uint256 _maxClaimed = maxClaimed(_minter);
        uint256 _alreadyClaimed = alreadyClaimed(_minter);
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
        require(
            _addresses.length < MAX_AMOUNTS,
            "The address amounts more than MAX_NUMBERS "
        );

        for (uint i = 0; i < _addresses.length; i++) {
            allClaimedAmounts[_addresses[i]]++;
        }
        emit AddWhitelist(_addresses);
    }

    function maxClaimed(address owner) public view returns (uint256) {
        return allClaimedAmounts[owner];
    }

    function alreadyClaimed(address owner) public view returns (uint256) {
        return alreadyClaimedAmounts[owner];
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
