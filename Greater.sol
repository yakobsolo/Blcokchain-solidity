// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract Greater {

    string public name;

    constructor()  {
        name = "hellow world";
    }
    function hello()  public view returns (string memory) {
        return name;
    }

    function setName(string memory newname)  public {
        name = newname;
    }


}
