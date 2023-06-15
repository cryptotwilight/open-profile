// SPDX-License-Identifier: APACHE 2.0
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../interfaces/IOpenProfileGateway.sol";
import "../interfaces/IOpenDirectory.sol";

contract OpenProfileGateway is IOpenProfileGateway, IOpenDirectory, IVersioning {

    
    string constant name = "OPEN_PROFILE_GATEWAY";
    uint256 constant version = 1; 


    address owner; 
    address admin; 
    IERC20Metadata currency; 
    address paymentCurrency;
    uint256 profilePrice; 

    IProfileFactory factory; 

    mapping(string=>address) profileByName; 
    mapping(address=>address) profileByOwner; 


    constructor(OpGatewayConfig memory _config)  {
        setConfig(_config);
    }

    function getName() pure external returns (string memory _name) {
        return name;
    }

    function getVersion() pure external returns (uint256 _version) {
        return version; 
    }

    function getPaymentCurrency() view external returns (address _apeCoin){
        return paymentCurrency;
    }

    function getProfilePrice() view external returns (uint256 _price){
        return profilePrice; 
    }
    
    function getProfile(address _owner) view external returns (address _profile){
        return profileByOwner[_owner];
    }   

    function findProfile(string memory _name) view external returns (address _profile){
        return profileByName[_name];
    }

    function buyProfile(Avatar memory _avatar) payable external returns (address _userProfile){
        
        _userProfile = factory.createProfile(_avatar);

        return _userProfile; 
    }


    //========================================== Internal ==========================================================

    function setConfig(OpGatewayConfig memory config) {

    }

}