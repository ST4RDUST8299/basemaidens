// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";


// File: BaseMaidens.sol

contract BaseMaidens is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    using Address for address;

    Counters.Counter private _tokenIdCounter;

    string private baseURI = "ipfs://bafybeibk5rlbacxj24ar6xl5igmievrzxrn62hwzmx6jkqk57f6ku3cggu/";
    string private _contractURI = "ipfs://bafybeihuis4vnn4ybcomvxzlfsnkajv6gkz6uqatay3qzki3u3nepgus44/contract";

    bool public frozenMetadata;
    event PermanentURI(string _baseURI, string _contractURI);

    uint256 public price = 0.007 ether;
    uint public constant MAXPURCHASE = 10;
    uint256 public constant MAXSUPPLY = 1111;

    bool public mintEnabled = false;

    constructor() ERC721("BaseMaidens", "BMAIDENS") {
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /**
     * @dev Set NFT Metadata folder link
     */

    function setBaseUri(string memory baseURI_) external onlyOwner {
        require(!frozenMetadata,"Metadata already frozen");
        baseURI = baseURI_;
    }

    function contractURI() public view returns (string memory) {        
        return _contractURI;
    }

    /**
     * @dev Set contract Metadata link
     */

    function setContractURI(string memory contractURI_) external onlyOwner {
        require(!frozenMetadata,"Metadata already frozen");
        _contractURI = contractURI_;
    }

    /**
     * @dev Freeze metadata so it may not be changed anymore
     */

    function freezeMetadata() external onlyOwner {
        frozenMetadata = true;
        emit PermanentURI(baseURI, _contractURI);
    }

    /**
     * @dev Mint function
     */

    function mint(uint numberOfTokens) public payable {
        require(mintEnabled == true, "Public minting hasn't yet begun");
        require(numberOfTokens <= MAXPURCHASE, "You can't mint that many at once");
        require(totalSupply() + numberOfTokens <= MAXSUPPLY, "Mint would exceed max supply");
        require(price * numberOfTokens <= msg.value, "Not enough ETH sent");       

        for(uint i = 0; i < numberOfTokens; i++) {
            _safeMint(_msgSender(), _tokenIdCounter.current());
            _tokenIdCounter.increment();
        }      
    }

    /**
     * @dev Owner only, mint NFT directly to an array of addresses
    */

    function promoMint(address [] memory _users) public onlyOwner {
        for (uint256 user; user < _users.length; user++) {
            _safeMint(_users[user], _tokenIdCounter.current());
            _tokenIdCounter.increment();
        } 
    }
    /**
     * @dev retrieve indexes of each of the NFT owned by the user
    */

    function tokensOwned(address owner) public view returns (uint256 [] memory) {
        uint256 [] memory Tokens = new uint256[](balanceOf(owner));
        if (balanceOf(owner) == 0) return (Tokens);
        for (uint256 index = 0; index < balanceOf(owner); index++) {
           Tokens[index] = tokenOfOwnerByIndex(owner, index);
        }
        return (Tokens);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev set public minting start using UNIX timestamp
     */

    function setMintEnabled(bool _mintEnabled) public onlyOwner {
        mintEnabled = _mintEnabled;
    }

    /**
     * @dev change mint price for any reason, likely won't be used
     */

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    /**
     * @dev get mint fees out of the contract
     */
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        Address.sendValue(payable(0xA725DbDdeE6F0776687Cf3834AB19bEbd9C1c8d5), balance * 34/100);
        Address.sendValue(payable(0x85a3921b9454b3281f22df744e5DA6a34126a269), balance * 33/100);
        Address.sendValue(payable(0xD0B4128CE20dA7c76CBcC9ee1668bdCd8562119a), balance * 33/100);

    }


    /**
     * @dev get mint fees out of the contract
     */
    function withdrawETHFallback() external onlyOwner {
        Address.sendValue(payable(owner()),address(this).balance);
    }
}
