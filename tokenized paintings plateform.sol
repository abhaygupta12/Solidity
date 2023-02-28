//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PaintingsMarketplace is ERC721, Ownable {

    uint256 public tokenIdCounter;
    mapping(uint256 => Painting) public paintings;

    struct Painting {
        uint256 id;
        string title;
        string artist;
        string imageURI;
        uint256 price;
        bool isAvailable; 
    }

    constructor() ERC721("PaintingsMarketplace", "PAINT") {}

    function mintPainting(string memory title, string memory artist, string memory imageURI, uint256 price) public onlyOwner {
        tokenIdCounter++;
        _mint(msg.sender, tokenIdCounter);
        paintings[tokenIdCounter] = Painting(tokenIdCounter, title, artist, imageURI, price, true);
    }

    function buyPainting(uint256 tokenId) public payable {
        Painting memory painting = paintings[tokenId];
        require(painting.isAvailable, "Painting not available");
        require(msg.value >= painting.price, "Insufficient funds");
        _transfer(painting.ownerOf(tokenId), msg.sender, tokenId);
        painting.isAvailable = false;
    } 
}