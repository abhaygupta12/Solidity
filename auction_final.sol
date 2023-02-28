// // SPDX-License-Identifier: MIT

// pragma solidity >=0.4.16 <0.9.0;

// contract Auction {
//     struct Bid {
//         address payable bidder;
//         uint256 amount;
//     }
    
//     struct AuctionInfo {
//         uint256 auctionId;
//         string description;
//         uint256 startTime;
//         uint256 endTime;
//         uint256 minBidValue;
//         uint256 bidCount;
//         address payable highestBidder;
//         uint256 highestBid;
//         bool isClosed;
//         mapping(address => uint256) bidderToAmount;
//         address[] bidders;
//         Bid[] bids;
//     }
//     address owner;
//     constructor(){
//      owner=msg.sender;
//     }
//     mapping(uint256 => AuctionInfo) public auctions;
    
//     event NewAuction(uint256 auctionId, string description, uint256 startTime, uint256 endTime, uint256 minBidValue);
//     event NewBid(uint256 auctionId, address bidder, uint256 amount);
//     event AuctionEnded(uint256 auctionId, address winner, uint256 amount);
    
//     modifier onlyOwner() {
//     require(msg.sender == owner, "Only the owner of this contract can call this function");
//     _;
   
// }

//     //function for creatiing the auction by the owner
//     function createAuction(uint256 _auctionId, string memory _description, uint256 _startTime, uint256 _endTime, uint256 _minBidValue) public {
//         require(_startTime < _endTime, "End time must be greater than start time");
//         AuctionInfo storage auction = auctions[_auctionId];
//         auction.auctionId = _auctionId;
//         auction.description = _description;
//         //
//         auction.startTime = block.timestamp+_startTime;
//         auction.endTime = block.timestamp+_startTime+_endTime;
//         auction.minBidValue = _minBidValue;
//         auction.highestBidder = payable(address(0));
//         auction.highestBid = 0;
//         auction.ended = false;
//         emit NewAuction(_auctionId, _description, _startTime, _endTime, _minBidValue);
//     }
    
//     function bid(uint256 _auctionId, uint256 _bidValue) public payable {
//         require(block.timestamp >= auctions[_auctionId].startTime, "Auction has not started yet");
//         require(block.timestamp <= auctions[_auctionId].endTime, "Auction has already ended");
//         require(_bidValue >= auctions[_auctionId].minBidValue, "Bid value must be greater than or equal to the minimum bid value");
//         require(_bidValue > auctions[_auctionId].highestBid, "Bid value must be greater than current highest bid");
//         auctions[_auctionId].highestBidder = payable(msg.sender);
//         auctions[_auctionId].highestBid = _bidValue;
//         auctions[_auctionId].bidderToAmount[msg.sender] += _bidValue;
//         auctions[_auctionId].bidders.push(msg.sender);
//         emit NewBid(_auctionId, msg.sender, _bidValue);
//     }
    
//     function endAuction(uint256 _auctionId) public {
//         require(block.timestamp > auctions[_auctionId].endTime, "Auction has not ended yet");
//         require(!auctions[_auctionId].ended, "Auction has already ended");
//         auctions[_auctionId].ended = true;
      
//     }

//     function getAllBids(uint _auctionId) public view onlyOwner returns (uint[] memory) {
   

//     uint[] memory bids = new uint[](auctions[_auctionId].bidCount);

//     for (uint i = 0; i < auctions[_auctionId].bidCount; i++) {
//         bids[i] = auctions[_auctionId].bids[i].amount;
//     }

//     return bids;
// }

// function closeAuction(address _winner) onlyOwner public {
//         require( _endTime== endTime, "Auction has not ended yet");
//         require(!isClosed, "Auction is already closed");
//         isClosed = true;
//         highestBidder = _winner;
//     }

// }

pragma solidity ^0.8.0;

contract AuctionPlatform {

    struct Auction {
        uint auctionID;
        string description;
        uint startTime;
        uint endTime;
        uint minBidValue;
        bool closed;
        uint highestBid;
        address payable highestBidder;
       
    }
     mapping(address => uint) bids;

    mapping(uint => Auction) public auctions; // Stores all the auctions
    uint public auctionCounter; // Keeps track of the number of auctions created

    // Event to emit when a new auction is created
    event NewAuction(uint auctionID, string description, uint startTime, uint endTime, uint minBidValue);

    // Event to emit when a bid is placed on an auction
    event NewBid(uint auctionID, address bidder, uint bidValue);

    // Event to emit when an auction is closed
    event AuctionClosed(uint auctionID, address winner, uint highestBid);

    // Function to create a new auction
    function createAuction(string memory _description, uint _startTime, uint _endTime, uint _minBidValue) public {
        require(_endTime > _startTime, "End time must be after start time"); // Ensure end time is after start time
        auctionCounter++; // Increment auction counter
        auctions[auctionCounter] = Auction(auctionCounter, _description, _startTime, _endTime, _minBidValue, false, 0, address(0)); // Create new auction
        emit NewAuction(auctionCounter, _description, _startTime, _endTime, _minBidValue); // Emit event
    }

    // Function to place a bid on an active auction
    function placeBid(uint _auctionID) public payable {
        Auction storage auction = auctions[_auctionID];
        require(block.timestamp >= auction.startTime, "Auction has not started yet"); // Ensure auction has started
        require(block.timestamp <= auction.endTime, "Auction has ended"); // Ensure auction has not ended
        require(msg.value >= auction.minBidValue, "Bid value must be greater than or equal to the minimum bid value"); // Ensure bid value is greater than or equal to the minimum bid value
        require(msg.value > auction.highestBid, "Bid value must be greater than the current highest bid"); // Ensure bid value is greater than the current highest bid
        if (auction.highestBid != 0) {
            auction.highestBidder.transfer(auction.highestBid); // Return the previous highest bid to the previous highest bidder
        }
        auction.highestBid = msg.value; // Update highest bid
        auction.highestBidder = msg.sender; // Update highest bidder
        auction.bids[msg.sender] += msg.value; // Update bidder's total bid value on this auction
        emit NewBid(_auctionID, msg.sender, msg.value); // Emit event
    }

    // Function to get the list of all bids placed on an auction
    function getBids(uint _auctionID) public view returns (address[] memory, uint[] memory) {
        Auction storage auction = auctions[_auctionID];
        address[] memory bidders = new address[](auction.highestBidder == address(0) ? 0 : 1); // If no bids have been placed, return an empty array
        uint[] memory bidValues = new uint[](auction.highestBidder == address(0) ? 0 : 1); // If no bids have been placed, return an empty array
        if (auction.highestBidder != address(0)) {
            bidders[0] = auction.highestBid;
        }
    }
}