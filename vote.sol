// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/Strings.sol";

contract Election {

    struct President {
        string name;
        string description;
    } 

    bool isActiveVoting = true;

    address private owner;

    uint256 public maxVotes;
    uint256 public totalVotes = 0;

    uint electionCompletionTime;

    President[] internal presidents;

    mapping (address => bool) internal isAddressVote;

    mapping (uint256 => uint256) internal votes;

    event VoteIsOk(uint256 _index, address _voterAddress, uint256 _totalVotes);

    error OnlyOwnerCanControlState();
    error ElectionWasStoppedByOwner();
    error OwnerCanNotVote();
    error YouHaveAlreadyVoted();
    error MaximumNumberOfVotesReached(uint256 _maxVotes);
    error TimeIsUp(uint256 _electionCompletionTime);
    error IndexDoesNotExist(uint256 _maxIndex);

    modifier onlyOvren(){
        require(owner == msg.sender, OnlyOwnerCanControlState());
        _;
    }


    constructor(President[] memory _initialPresidents, uint256 _maxVotes, uint256 _electionTime){
        maxVotes = _maxVotes;
        owner= msg.sender;
        electionCompletionTime = block.timestamp + _electionTime;

        uint len = _initialPresidents.length;

        if(len <= 0) {
            addPresident("John", "Some description about John");
        } else {
            for (uint24 i; i < len; i++){
                addPresident(_initialPresidents[i].name, _initialPresidents[i].description);
            }
        }
    }

    function setStateOfVoting(bool _isActiveVoting) public onlyOvren {
        isActiveVoting = _isActiveVoting;
    } 

    function addVotingTime(uint256 _additionalTime) public onlyOvren {
        electionCompletionTime += _additionalTime;
    }


    function vote(uint256 _indexOfPresident) public {
        require(isActiveVoting == true, ElectionWasStoppedByOwner());
        require(owner != msg.sender, OwnerCanNotVote());
        require(totalVotes < maxVotes, MaximumNumberOfVotesReached(maxVotes));
        require(block.timestamp <= electionCompletionTime, TimeIsUp(electionCompletionTime));
        require(isAddressVote[msg.sender] == false, YouHaveAlreadyVoted());
        require(_indexOfPresident < presidents.length, IndexDoesNotExist(presidents.length));

        isAddressVote[msg.sender] = true;
        votes[_indexOfPresident] += 1;
        totalVotes +=1;

        emit VoteIsOk(_indexOfPresident, msg.sender, totalVotes);
    }

      function addPresident(string memory _name, string memory _description) public {
        presidents.push(President(_name, _description));
    }

    function getPresidentsInfoString() public view returns (string memory) {
        uint len = presidents.length;

        string memory presidentsInfo = '';

        for (uint256 i = 0; i < len; i++) {
            presidentsInfo = string.concat(presidentsInfo, Strings.toString(i), ") ", presidents[i].name, " - '", presidents[i].description, "' ");
        }

        return presidentsInfo;
    }

    function getLeaderIndex() public view returns(uint256) {
        uint256 maxValue = 0;
        uint256 leaderIndex = 0;
     

        for(uint256 i = 0; i < presidents.length; i++){
            if(votes[i] > maxValue){
                maxValue = votes[i];
                leaderIndex = i;
            }
        }

        return leaderIndex;
    }

    function getVotesOfPresident(uint256 _indexOfPresident) public view returns(string memory){
        require(_indexOfPresident < presidents.length, IndexDoesNotExist(presidents.length));

        return string.concat(presidents[_indexOfPresident].name, ': ', Strings.toString(votes[_indexOfPresident]));
    }
}
//owner, stop voiting, electionTime - block.timestamp 