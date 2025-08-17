// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/Strings.sol";

contract Election {

    struct President {
        string name;
        string description;
    }

    President[] internal presidents;

    mapping (address => bool) internal isAddressVote;

    mapping (uint256 => uint256) internal votes;

    function addPresident(string memory _name, string memory _description) public {
        presidents.push(President(_name, _description));
    }

    function getPresidents() public view returns (string memory) {
        uint len = presidents.length;

        string memory presidentsInfo = '';

        for (uint i = 0; i < len; i++) {
            presidentsInfo = string.concat(presidentsInfo, Strings.toString(i), ") ", presidents[i].name, " - '", presidents[i].description, "' ");
        }

        return presidentsInfo;
    }

    function getVotesOfPresident(uint256 _indexOfPresident) public view returns(string memory){
        require(_indexOfPresident < presidents.length, "President with this index doesn't exist");

        return string.concat(presidents[_indexOfPresident].name, ': ', Strings.toString(votes[_indexOfPresident]));
    }

    constructor(){
        addPresident("John", "Some description about John");
    }

    function vote(uint256 _indexOfPresident) public {
        require(isAddressVote[msg.sender] == false, "You've already voted");
        require(_indexOfPresident < presidents.length, "President with this index doesn't exist");

        isAddressVote[msg.sender] = true;
        votes[_indexOfPresident] += 1;
    }
}