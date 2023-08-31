// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";

contract AINft is Ownable, ERC2981, ERC721A, ReentrancyGuard {
    //using
    using Address for address;
    using SafeMath for uint256;

    //variables
    string public _baseTokenURI;
    mapping(uint256 => bool) public lockedTokens;
    mapping(address => bool) public lockWhitelists;
    mapping(address => bool) public mintWhitelists;
    mapping(address => bool) public burnWhitelists;

    constructor(
        string memory name,
        string memory symbol,
        address _royaltyReceiveAddress,
        uint96 _feeNumerator
    )ERC721A(name, symbol){
        _setDefaultRoyalty(_royaltyReceiveAddress, _feeNumerator);
    }

    function setRoyaltyReceive(address _royaltyReceiveAddress, uint96 _feeNumerator) public onlyOwner {
        _setDefaultRoyalty(_royaltyReceiveAddress, _feeNumerator);
    }

    function setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) external onlyOwner {
        _setTokenRoyalty(tokenId, receiver, feeNumerator);
    }

    function addLockWhitelist(address proxy) public onlyOwner {
        lockWhitelists[proxy] = true;
    }

    function removeLockWhitelist(address proxy) public onlyOwner {
        lockWhitelists[proxy] = false;
    }

    function addMintWhitelist(address proxy) public onlyOwner {
        mintWhitelists[proxy] = true;
    }

    function removeMintWhitelist(address proxy) public onlyOwner {
        mintWhitelists[proxy] = false;
    }

    function addBurnWhitelist(address proxy) public onlyOwner {
        burnWhitelists[proxy] = true;
    }

    function removeBurnWhitelist(address proxy) public onlyOwner {
        burnWhitelists[proxy] = false;
    }

    function burn(uint256 tokenId) external {
        require(
            burnWhitelists[_msgSender()],
            "AINft: must be valid burn whitelist"
        );
        _burn(tokenId, false);
    }

    function mint(address to, uint256 quantity) external {
        require(
            mintWhitelists[_msgSender()],
            "AINft: must be valid mint whitelist"
        );
        _safeMint(to, quantity);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function setDefaultURI(string memory defaultURI) external onlyOwner {
        _baseTokenURI = defaultURI;
    }

    function lock(uint256 tokenId) external {
        require(
            lockWhitelists[_msgSender()],
            "AINft: must be valid lock whitelist"
        );
        require(_exists(tokenId), "AINft: must be valid tokenId");
        require(!lockedTokens[tokenId], "AINft: token has already locked");
        lockedTokens[tokenId] = true;
    }

    function isLocked(uint256 tokenId) external view returns (bool) {
        return lockedTokens[tokenId];
    }

    function unlock(uint256 tokenId) external {
        require(
            lockWhitelists[_msgSender()],
            "AINft: must be valid lock whitelist"
        );
        require(_exists(tokenId), "AINft: must be valid tokenId");
        require(lockedTokens[tokenId], "AINft: token has already unlocked");
        lockedTokens[tokenId] = false;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        _resetTokenRoyalty(tokenId);
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override(ERC721A) {
        if (quantity == 1) {
            require(!lockedTokens[startTokenId], "AINft: can not transfer locked token");
            super._beforeTokenTransfers(from, to, startTokenId, quantity);
        }
    }

    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721A)
    returns (string memory)
    {
        require(
            _exists(tokenId),
            "AINftURL: URI query for nonexistent token"
        );
        return string(
            abi.encodePacked(
                _baseTokenURI,
                Strings.toString(tokenId),
                ".json"
            ));
    }
}
