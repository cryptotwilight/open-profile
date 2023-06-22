// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

// version 5

import {Avatar} from "../interfaces/IOpenProfile.sol";

struct OpGatewayConfig {
 
    uint256 profilePrice; 
    address registry ; // owner, admin, payment currency

}

interface IOpenProfileGateway {

    function getPaymentCurrency() view external returns (address _apeCoin);

    function getProfilePrice() view external returns (uint256 _price);

    function findProfile(string memory _name) view external returns (address _profile);

    function buyProfile(Avatar memory _avatar) payable external returns (address _userProfile);

}