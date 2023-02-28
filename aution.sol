//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionPlatform {
//this struct contains information about each auction.
    struct Auction {
        uint auctionId;
        string description;
        uint startTime;
        uint endTime;
        uint minBidValue;
        address auctionOwner;
        uint highestBid;
        address highestBidder;
        bool closed;
    }
     mapping(address => uint) bids;
//mapping auctionID to Auction struct.
    mapping(uint => Auction) public auctions;
//maps addresses to arrays of auctionIDs representing the auction where address place bids.
    mapping(address => uint[]) public bidsByBidder;
// creating new Auction.
    event NewAuction(uint auctionId, string description, uint startTime, uint endTime, uint minBidValue);
// placing a new bid.
    event NewBid(uint auctionId, address bidder, uint bidValue);
//closing an auction.
    event AuctionClosed(uint auctionId, address winner, uint highestBid);
// this function allows auction owner to create a new auction.
    function createAuction(uint _auctionId, string memory _description, uint _startTime, uint _endTime, uint _minBidValue) public {
        require(_endTime > _startTime, "End time must be greater than start time");
        //function adds the new auction to the 'auctions' mapping.
        auctions[_auctionId] = Auction(_auctionId, _description, _startTime, _endTime, _minBidValue, msg.sender, 0, address(0), false);
        // emits a 'NewAuction' event.
        emit NewAuction(_auctionId, _description, _startTime, _endTime, _minBidValue);
    }
//'placebid' function allow users to place bids on active auctions
    function placeBid(uint _auctionId, uint _bidValue) public {
        Auction storage auction = auctions[_auctionId];  //doubt
        require(auction.startTime <= block.timestamp && auction.endTime > block.timestamp, "Auction not active");
        require(_bidValue >= auction.minBidValue, "Bid value too low");
        require(_bidValue > auction.highestBid, "Bid value too low");
        bids[msg.sender] = _bidValue;
        auction.highestBid = _bidValue;
        auction.highestBidder = msg.sender;
        bidsByBidder[msg.sender].push(_auctionId);
        emit NewBid(_auctionId, msg.sender, _bidValue);
    }
// this function alow auction owner to see the list of all bids placed on their auction.
    function getBids(uint _auctionId) public view returns (address[] memory, uint[] memory) {
        Auction storage auction = auctions[_auctionId];  //doubt
        uint len = 0;
        for (uint i = 0; i < bidsByBidder[auction.auctionOwner].length; i++) {
            if (bidsByBidder[auction.auctionOwner][i] == _auctionId) {
                len++;
            }
        }
        address[] memory addrs = new address[](len);
        uint[] memory values = new uint[](len);
        uint j = 0;
        for (uint i = 0; i < bidsByBidder[auction.auctionOwner].length; i++) {
            uint bidAuctionId = bidsByBidder[auction.auctionOwner][i];
            if (bidAuctionId == _auctionId) {
                addrs[j] = msg.sender;
                values[j] = bids[msg.sender];
                j++;
            }
        }
        return (addrs, values);
    }
// this function allow bidder to see a list of all auction where they have placed bids.
    function getAuctionsByBidder() public view returns (uint[] memory) {
        return bidsByBidder[msg.sender];
    }
// this function allow auction owner to mark an auction as closed. 
    function closeAuction(uint _auctionId) public {
        Auction storage auction = auctions[_auctionId];
        require(auction.auctionOwner == msg.sender, "Only auction owner can close auction");
        require(auction.endTime <= block.timestamp, "Auction not yet closed");
        require(!auction.closed, "Auction already closed");
        auction.closed = true;
        emit AuctionClosed(_auctionId, auction.highestBidder, auction.highestBid);
    }
}