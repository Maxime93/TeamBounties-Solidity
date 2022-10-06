# tb-solidity

THIS IS NOT SECURITY TESTED!
Do not deploy and use the contract as is. It has not been security tested and contains bugs for sure. This is only a small side project for me to get a bit more familiar with Brownie and Solidity.

### Description
This smart contract allows teams to register themselves and define stakes. When teams are registered they can get paid and the sum is split across participants (depending on their stake). Participants can safely transfer their earnings to their address.

This allows teams that are getting paid in ETH to collaborate and safely get paid without trusting a third party.

Workflow (see example in intergration tests):
1. Create a new team
2. Potentially propose/vote/add new participants
3. Team gets paid
4. Voting to withdraw
5. Withdraw funds
