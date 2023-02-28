// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
//import  the ERC721 contract from openZeppelin to inherit its functionality for creating NFTs.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//import counters that can only be incremented or decremented by one.
import "@openzeppelin/contracts/utils/Counters.sol";

contract PaintingsMarketplace is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address payable public owner;
    uint256 public listingPrice = 0.001 ether;

    constructor() ERC721("PaintingsMarketplace", "PNT") {
        owner = payable(msg.sender);
    }
// define struct that holds the relevant information.
    struct Painting {
        uint256 id;
        string name;
        string description;
        string image;
        address payable owner;
        uint256 price;
        bool sold;
    }
// mapping to keep track of all the paintings on the plateform.
    mapping(uint256 => Painting) public paintings;
// define an event when painting is listed.
    event PaintingListed(uint256 indexed paintingId, address indexed owner);
//define an event when painting is sold.
    event PaintingSold(uint256 indexed paintingId, address indexed buyer, uint256 price);
// modifier to restrict access to certain functions only to the owner of the contract.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
//this function allows anyone to list a painting for sale by providing the neccessary information & paying the listed price.
    function listPainting(string memory name, string memory description, string memory image, uint256 price) public payable {
        require(msg.value == listingPrice, "Listing price must be paid");
        _tokenIds.increment();
        uint256 paintingId = _tokenIds.current();
        paintings[paintingId] = Painting(paintingId, name, description, image, payable(msg.sender), price, false);
        emit PaintingListed(paintingId, msg.sender);
    }
// this function which allow a buyer to purchase a painting by sending the correct amount of ether and receciving the ownership.
    function buyPainting(uint256 paintingId) public payable {
        Painting storage painting = paintings[paintingId];
        require(!painting.sold, "Painting is already sold");
        require(msg.value == painting.price, "Sent ether value does not match painting price");
        painting.sold = true;
        painting.owner.transfer(msg.value);
        _safeMint(msg.sender, paintingId);
        emit PaintingSold(paintingId, msg.sender, painting.price);
    }
// this function allow owner to chage the listing price.
    function setListingPrice(uint256 newPrice) public onlyOwner {
        listingPrice = newPrice;
    }

    // function withdraw() public onlyOwner {
    //     uint256 balance = address(this).balance;
    //     owner.transfer(balance);
    // }
}