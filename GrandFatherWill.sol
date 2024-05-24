// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.0;


contract GrandFatherWill {

    address owner;
    uint fortune;
    bool isPassed;



    constructor () payable {
        owner = msg.sender;
        fortune = msg.value;
        isPassed = false;
    }

    modifier onlyowner {
        require(owner ==msg.sender, "only owner of this contract have access");
        _;

    }

    modifier  ifPassed {
        require(isPassed == true, "the owner must pass");
        _;
    }


    address payable[] familyMember;
    mapping(address => uint) givenInheritance;


    function inherit(address payable memberadress, uint amount) payable public onlyowner{
        familyMember.push(memberadress);
        givenInheritance[memberadress] = amount;

    }


    function payAll() private ifPassed {
        for (uint i = 0; i<familyMember.length; i++) {
            familyMember[i].transfer(givenInheritance[familyMember[i]]);

        }
    }

    function execute()   public onlyowner{
        isPassed = true;
        payAll();

    }




}
