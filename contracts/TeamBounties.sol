// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TeamBounties {
    using SafeMath for uint256;

    event NewTeam(uint team_id, string name, uint number_participants, address payment);

    struct Participant {
        uint share;
        uint accept_vote;
        uint team_id;
    }
    mapping(address => Participant) new_participants;

    struct Team {
        string name;
        address[] participant_addresses;
        uint[] participant_shares;
        uint balance;
        uint withdraw_votes;
        address payable _payment_address;
    }
    Team[] public teams;

    function getSum(uint[] memory array) public pure returns(uint) {
        uint i;
        uint sum = 0;

        for(i = 0; i < array.length; i++)
            sum += array[i];
        return sum;
    }

    function computeMajority(uint votes, uint total) private pure returns (bool) {
        uint256 oneHundred = 100;
        return oneHundred.mul(votes).div(total) > 50;
    }

    modifier majorityVote(uint _id) {
        require(computeMajority(teams[_id].withdraw_votes, getSum(teams[_id].participant_shares)));
        _;
    }

    function createTeam(
        string memory _name,
        address[] memory _addresses,
        uint[] memory _shares,
        address _payment_address
        ) public {
            require(_addresses.length == _shares.length);
            teams.push(Team(_name, _addresses, _shares, 0, 0, payable(_payment_address)));
            uint id = teams.length - 1;
            emit NewTeam(id, _name, _addresses.length, _payment_address);
    }

    function getTeam(uint id) public view returns (Team memory) {
        return teams[id];
    }

    function proposeParticipant(address _participant, uint _share, uint _team_id) public {
        require(partOfTeam(_team_id));
        new_participants[_participant] = Participant(_share, 0, _team_id);
    }

    function voteNewParticipant(address _new_participant, uint team_id) public {
        require(partOfTeam(new_participants[_new_participant].team_id));
        uint idx = indexOfTeam(team_id);
        new_participants[_new_participant].accept_vote += teams[team_id].participant_shares[idx];

        uint votes = new_participants[_new_participant].accept_vote;
        uint team_voting_power = getSum(teams[team_id].participant_shares);

        // TODO: Make function that computes majority vote
        if (computeMajority(votes, team_voting_power)){
            addParticipant(team_id, _new_participant, new_participants[_new_participant].share);
        }
    }

    function addParticipant(uint _team_id, address _new_participant, uint _share) public {
        require(partOfTeam(_team_id));
        teams[_team_id].participant_addresses.push(_new_participant);
        teams[_team_id].participant_shares.push(_share);
    }

    // Someone from the team can withdraw funds to paymentsplitter
    function withdraw(uint id) external payable majorityVote(id){
        require(partOfTeam(id)); // Verify person calling function is in the team
        require(teams[id].balance > 0 ether); // Verify this team has a balance

        // This has a bug
        require (computeMajority(teams[id].withdraw_votes, teams[id].participant_shares.length)); // Verify withdraw_votes majority; Security problem here

        teams[id]._payment_address.transfer(teams[id].balance);
        teams[id].balance = 0;
    }

    // Receive a payment for a team
    function payTeam(uint id) public payable {
        require(id <= teams.length - 1, "Team does not exist.");
        require(msg.value > 0 ether);
        teams[id].balance += msg.value;
    }

    // Verify that an address is part of a specific team
    function partOfTeam(uint id) public view returns (bool) {
        for (uint i; i <= teams[id].participant_addresses.length; i++) {
            if (teams[id].participant_addresses[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    // Return the postion of the address
    function indexOfTeam(uint id) public view returns (uint) {
        uint counter = 0;
        for (uint i; i <= teams[id].participant_addresses.length; i++) {
            if (teams[id].participant_addresses[i] == msg.sender) {
                return counter;
            }
            counter.add(1);
        }
        return counter;
    }

    function voteWithdraw(uint id) public {
        // We check that msg.sender is in teams[id].participant_addresses
        require(partOfTeam(id));

        // We get the the level of participation for that address
        uint idx = indexOfTeam(id);
        uint share = teams[id].participant_shares[idx];

        // We do a weighted vote based on how many shares that address has
        teams[id].withdraw_votes += share;
    }
}
