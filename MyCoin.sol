// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract MyCoin {

    address minter;
    mapping (address => uint) balances;


    event havSent(address from, address to,uint amount);

    error insufficientBalance( uint senderbalance, uint amountrequired);

    constructor () {
        minter = msg.sender;
        

    }


    function mint(address receiver, uint amount) public  {
        require(msg.sender == minter, "sender is not the minter");
        balances[receiver] += amount;

    } 

    function Send(address receiver, uint amount) public {

        if (balances[msg.sender] < amount) {
            revert insufficientBalance({senderbalance: balances[msg.sender], amountrequired: amount});
        }

        balances[msg.sender] -=amount;
        balances[receiver] += amount;

        emit havSent(msg.sender, receiver, amount);
    }


}
