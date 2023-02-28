//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionPlatform {
    // Define a struct to represent an auction
    struct Auction {
        string description;
        uint startTime;
        uint endTime;
        uint minBidValue;
        address auctionOwner;
        address highestBidder;
        uint highestBid;
        bool closed;
    }
    // Define a mapping to store all auctions
    mapping (uint => Auction) public auctions;
    
    // Define a mapping to store all bids
    mapping (uint => mapping (address => uint)) public bids;
    
    // Define events to emit when certain actions are taken
    event AuctionCreated(uint auctionId);
    event BidPlaced(uint auctionId, address bidder, uint bidValue);
    event AuctionClosed(uint auctionId, address winner, uint highestBid);
    
    // Function to create a new auction
    function createAuction(uint auctionId, string memory description, uint startTime, uint endTime, uint minBidValue) public {
        // Make sure the auction ID does not already exist
        require(auctions[auctionId].startTime == 0, "Auction ID already exists.");
        // Make sure the end time is after the start time
        require(endTime > startTime, "End time must be after start time.");
        // Create the new auction
        auctions[auctionId] = Auction(description, startTime, endTime, minBidValue, msg.sender, address(0), 0, false);
        emit AuctionCreated(auctionId);
    }
    
    // Function to place a bid on an active auction
    function placeBid(uint auctionId, uint bidValue) public payable {
        // Make sure the auction is active
        require(block.timestamp >= auctions[auctionId].startTime && block.timestamp <= auctions[auctionId].endTime, "Auction is not active.");
        // Make sure the bid value is higher than the current highest bid
        require(bidValue > auctions[auctionId].highestBid, "Bid value must be higher than current highest bid.");
        // Make sure the bid value is greater than or equal to the minimum bid value
        require(bidValue >= auctions[auctionId].minBidValue, "Bid value must be greater than or equal to the minimum bid value.");
        // Record the bid
        bids[auctionId][msg.sender] = bidValue;
        // Update the highest bid
        auctions[auctionId].highestBidder = msg.sender;
        auctions[auctionId].highestBid = bidValue;
        emit BidPlaced(auctionId, msg.sender, bidValue);
    }
    
   // Function for auction owner to see list of all bids on their auction
    function viewBidsOnAuction(uint auctionId) public view returns (address[] memory, uint[] memory) {
        address[] memory bidders = new address[](getNumberOfBidsOnAuction(auctionId));
        uint[] memory bidValues = new uint[](getNumberOfBidsOnAuction(auctionId));
        uint index = 0;
        for (uint i = 0; i < getNumberOfBidsOnAuction(auctionId); i++) {
            if (bids[auctionId][getBidderOnAuctionAtIndex(auctionId, i)] > 0) {
                bidders[index] = getBidderOnAuctionAtIndex(auctionId, i);
                bidValues[index] = bids[auctionId][bidders[index]];
                index++; 
            }
        }
        return (bidders, bidValues);
    }
}