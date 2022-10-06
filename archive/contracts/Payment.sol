// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/finance/PaymentSplitter.sol";

contract Payment is PaymentSplitter {
    constructor (address[] memory _payees, uint256[] memory _shares) PaymentSplitter(_payees, _shares) payable {}


}

// ["0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
// "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
// "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"]
// ---- ----
// [50, 20, 20, 10]