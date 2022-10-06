// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract TeamBounties {
    event NewTeam(uint team_id, string name, uint number_participants, address payment);

    struct Team {
        string name;
        address[] participant_addresses;
        uint[] participant_shares;
        uint balance;
        uint _withdraw_votes;
        address payable _payment_address;
    }
    Team[] public teams;

    modifier majorityVote(uint _id) {
        require(100 * teams[_id]._withdraw_votes >= 50);
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

    // Someone from the team can withdraw funds to paymentsplitter
    function withdraw(uint id) external payable majorityVote(id){
        require(partOfTeam(id)); // Verify person calling function is in the team
        require(teams[id].balance > 0 ether); // Verify this team has a balance
        require(100 * teams[id]._withdraw_votes / teams[id].participant_shares.length > 50); // Verify _withdraw_votes majority; Security problem here

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
            counter++;
        }
        return counter;
    }

    function vote_withdraw(uint id) public {
        // We check that msg.sender is in teams[id].participant_addresses
        require(partOfTeam(id));

        // We get the the level of participation for that address
        uint idx = indexOfTeam(id);
        uint share = teams[id].participant_shares[idx];

        // We do a weighted vote based on how many shares that address has
        teams[id]._withdraw_votes += share;
    }
}


// team1, ["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"], [50,50], "0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C"