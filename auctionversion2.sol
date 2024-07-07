// SPDX-License-Identifier: MIT
pragma solidity ^0.4.17;

contract Auction {

    // Structure to hold details of the item
    struct Item {
        uint itemId; // ID of the item
        uint[] itemTokens; // Tokens bid in favor of the item
    }

    // Structure to hold the details of a person
    struct Person {
        uint remainingTokens; // Tokens remaining with bidder
        uint personId; // It serves as tokenId as well
        address addr; // Address of the bidder
    }

    mapping(address => Person) tokenDetails; // Mapping address to person  
    Person[4] bidders; // Array containing 4 person objects
    Item[3] public items; // Array containing 3 item objects
    address[3] public winners; // Array for address of winners
    address public beneficiary; // Owner of the smart contract
    
    uint bidderCount = 0; // Counter

    // Constructor
    function Auction() public {
        beneficiary = msg.sender;

        // Initialize items
        items[0] = Item({itemId: 0, itemTokens: new uint[](0)});
        items[1] = Item({itemId: 1, itemTokens: new uint[](0)});
        items[2] = Item({itemId: 2, itemTokens: new uint[](0)});
    } 

    // Function to register bidders
    function register() public payable {    
        bidders[bidderCount].personId = bidderCount;
        bidders[bidderCount].addr = msg.sender;
        bidders[bidderCount].remainingTokens = 5; // Only 5 tokens
        tokenDetails[msg.sender] = bidders[bidderCount];
        bidderCount++;
    } 

    // Function to bid
    function bid(uint _itemId, uint _count) public {
        require(tokenDetails[msg.sender].remainingTokens >= _count);
        require(tokenDetails[msg.sender].remainingTokens > 0);
        require(_itemId < 3);

        tokenDetails[msg.sender].remainingTokens -= _count;
        bidders[tokenDetails[msg.sender].personId].remainingTokens = tokenDetails[msg.sender].remainingTokens;

        Item storage bidItem = items[_itemId];
        for (uint i = 0; i < _count; i++) {
            bidItem.itemTokens.push(tokenDetails[msg.sender].personId);
        }
    } 

    // Part 2 Task 1. Create a modifier named "onlyOwner" to ensure that only the owner is allowed to reveal winners.
    modifier onlyOwner() {
        require(msg.sender == beneficiary);
        _;
    }

    // Function to reveal winners, restricted to the owner
    function revealWinners() public onlyOwner {
        for (uint id = 0; id < 3; id++) {
            Item storage currentItem = items[id];
            if (currentItem.itemTokens.length != 0) {
                uint randomIndex = (block.number / currentItem.itemTokens.length) % currentItem.itemTokens.length;
                uint winnerId = currentItem.itemTokens[randomIndex];
                winners[id] = bidders[winnerId].addr;
            }
        }
    }  

    // Miscellaneous methods: Below methods are used to assist grading. Please DO NOT CHANGE THEM.
    function getPersonDetails(uint id) public constant returns(uint, uint, address) {
        return (bidders[id].remainingTokens, bidders[id].personId, bidders[id].addr);
    }

    function getItemDetails(uint id) public constant returns(uint, uint[]) {
        return (items[id].itemId, items[id].itemTokens);
    }
}
