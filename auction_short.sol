pragma solidity ^0.8.0;

contract Auction {
    struct Bid {
        address bidder;
        uint256 value;
    }
    
    struct AuctionItem {
        uint256 id;
        string description;
        uint256 startTime;
        uint256 endTime;
        uint256 minBidValue;
        Bid[] bids;
        bool closed;
        address winner;
    }
    
    mapping(uint256 => AuctionItem) public auctions;
    uint256 public auctionCounter;
    
    function createAuction(string memory _description, uint256 _startTime, uint256 _endTime, uint256 _minBidValue) public returns (uint256) {
        require(_startTime < _endTime, "Invalid auction times");
        auctionCounter++;
        auctions[auctionCounter] = AuctionItem({
            id: auctionCounter,
            description: _description,
            startTime: _startTime,
            endTime: _endTime,
            minBidValue: _minBidValue,
            closed: false,
            winner: address(0),
            bids: new Bid[](0)
        });
        return auctionCounter;
    }
    
    function placeBid(uint256 _auctionId, uint256 _bidValue) public payable {
        AuctionItem storage auction = auctions[_auctionId];
        require(block.timestamp >= auction.startTime, "Auction not started");
        require(block.timestamp < auction.endTime, "Auction ended");
        require(_bidValue >= auction.minBidValue, "Bid value too low");
      //  require(msg.value == _bidValue, "Bid value doesn't match sent ether");
        require(!auction.closed, "Auction closed");
        require(msg.sender != auction.winner, "You are already the highest bidder");
        
        auction.bids.push(Bid({
            bidder: msg.sender,
            value: _bidValue
        }));
        auction.winner = msg.sender;
    }
    
    function closeAuction(uint256 _auctionId) public {
        AuctionItem storage auction = auctions[_auctionId];
        require(!auction.closed, "Auction already closed");
        // require(msg.sender == auction.winner, "Only winner can close the auction");
        auction.closed = true;
    }
    
    function getBidsCount(uint256 _auctionId) public view returns (uint256) {
        return auctions[_auctionId].bids.length;
    }
    
    function getBid(uint256 _auctionId, uint256 _index) public view returns (address, uint256) {
        Bid storage bid = auctions[_auctionId].bids[_index];
        return (bid.bidder, bid.value);
    }
    
    function getWinner(uint256 _auctionId) public view returns (address) {
        return auctions[_auctionId].winner;
    }
}