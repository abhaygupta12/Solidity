// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionPlatform {
    // Struct to represent an auction
    struct Auction {
        uint256 id;
        string description;
        uint256 startTime;
        uint256 endTime;
        uint256 minBidValue;
        bool closed;
        address highestBidder;
        uint256 highestBid;
        mapping(address => uint256) bids;
    }

    // Mapping of auction ID to Auction struct
    mapping(uint256 => Auction) public auctions;

    // Mapping of address to a list of auction IDs where they placed bids
    mapping(address => uint256[]) public bidderAuctions;

    // Event emitted when a new auction is created
    event AuctionCreated(uint256 auctionId);

    // Event emitted when a bid is placed on an auction
    event BidPlaced(uint256 auctionId, address bidder, uint256 bidValue);

    // Event emitted when an auction is closed
    event AuctionClosed(uint256 auctionId, address winner, uint256 winningBid);

    // Function to create a new auction
    function createAuction(uint256 id, string memory description, uint256 startTime, uint256 endTime, uint256 minBidValue) public {
        // Make sure the auction ID does not already exist
        require(auctions[id].id != id, "Auction with this ID already exists");

        // Make sure the start time is in the future and end time is after start time
        require(startTime > block.timestamp, "Start time must be in the future");
        require(endTime > startTime, "End time must be after start time");

        // Create the new auction
        Auction storage auction = auctions[id];
        auction.id = id;
        auction.description = description;
        auction.startTime = startTime;
        auction.endTime = endTime;
        auction.minBidValue = minBidValue;
        auction.closed = false;

        // Emit an event to notify that a new auction was created
        emit AuctionCreated(id);
    }

    // Function to place a bid on an auction
    function placeBid(uint256 id, uint256 bidValue) public {
        // Make sure the auction exists
        require(auctions[id].id == id, "Auction with this ID does not exist");

        // Make sure the auction is still open
        require(block.timestamp < auctions[id].endTime, "Auction is closed");

        // Make sure the bid is higher than the current highest bid and greater than or equal to the minimum bid value
        require(bidValue > auctions[id].highestBid, "Bid must be higher than current highest bid");
        require(bidValue >= auctions[id].minBidValue, "Bid must be greater than or equal to minimum bid value");

        // Record the new highest bid
        Auction storage auction = auctions[id];
        auction.highestBidder = msg.sender;
        auction.highestBid = bidValue;
        auction.bids[msg.sender] = bidValue;

        // Add the auction to the list of auctions where the bidder placed a bid
        bidderAuctions[msg.sender].push(id);

        // Emit an event to notify that a bid was placed
        emit BidPlaced(id, msg.sender, bidValue);
    }

    // // Function for auction owner to see list of all bids placed on their auction
    // function getAuctionBids(uint256 id) public view returns (address[] memory, uint256[] memory) {
    //     // Make sure the auction exists
    //     require(auctions[id].id == id, "Auction with this ID does not exist");

    //     // Create arrays to hold the bidders and their respective bids
    //     address[] memory
    // }
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