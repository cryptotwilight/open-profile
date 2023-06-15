// SPDX-License-Identifier: APACHE 2.0
pragma solidity ^0.8.20;

import {Avatar} from "../interfaces/IOpenProfile.sol";

struct OpGatewayConfig {
    address owner; 
    address admin; 
    address paymentCurrency; 
    uint256 profilePrice; 
    address profileFactory; 

}

interface IOpenProfileGateway {

    function getPaymentCurrency() view external returns (address _apeCoin);

    function getProfilePrice() view external returns (uint256 _price);
    
    function getProfile(address _owner) view external returns (address _profile);

    function findProfile(string memory _name) view external returns (address _profile);

    function buyProfile(Avatar memory _avatar) payable external returns (address _userProfile);

}