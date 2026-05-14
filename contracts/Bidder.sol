// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

contract Bidder {
    
    string public name = "Yakob";
    uint public bidAmount;
    bool public  eligible;
    uint constant minBid = 1000;
     
    function setName(string memory nm) public {
        name = nm;
        
    }
    
    function setBidAmount(uint x) public {
        bidAmount  = x;
    }
  
    function determineEligibility() public {
        if (bidAmount >= minBid ) eligible = true;
        else eligible = false;
 
    }


}
