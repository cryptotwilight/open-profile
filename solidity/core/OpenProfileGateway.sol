// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "https://github.com/Block-Star-Logic/open-version/blob/main/blockchain_ethereum/solidity/V1/interfaces/IOpenVersion.sol";
import "https://github.com/Block-Star-Logic/open-register/blob/main/blockchain_ethereum/solidity/V1/interfaces/IOpenRegister.sol";


import "../interfaces/IOpenProfileGateway.sol";
import "../interfaces/IOpenDirectory.sol";
import "../interfaces/IProfileFactory.sol";

contract OpenProfileGateway is IOpenProfileGateway, IOpenDirectory, IOpenVersion {

    
    string constant name        = "OPEN_PROFILE_GATEWAY";
    uint256 constant version    = 6; 
    address self; 

    string constant gatewayOwnerRegistryKey             = "OPEN_PROFILE_GATEWAY_OWNER";
    string constant gatewayAdminRegistryKey             = "OPEN_PROFILE_GATEWAY_ADMIN";
    string constant gatewayPaymentCurrencyRegistryKey   = "OPEN_PROFILE_GATEWAY_PAYMENT_CURRENCY";
    string constant gatewayProfileFactoryRegistryKey    = "OP_PROFILE_FACTORY";
    string constant gatewaySafeHarbourRegistryKey       = "OPEN_PROFILE_SAFE_HARBOUR";
    string constant RegisterRegistryKey                  = "REGISTER";

    address owner; 
    address admin; 
    address SAFE_HARBOUR; 
    
    IOpenRegister registry;     
    IERC20Metadata paymentCurrency; 
    IProfileFactory factory; 
    
    uint256 profilePrice; 

    mapping(string=>address) profileByName; 
    mapping(address=>address) profileByOwner; 

    constructor(OpGatewayConfig memory _config)  {
        setConfig(_config);
        self = address(this);
    }

    function getName() pure external returns (string memory _name) {
        return name;
    }

    function getVersion() pure external returns (uint256 _version) {
        return version; 
    }

    function getPaymentCurrency() view external returns (address _apeCoin){
        return address(paymentCurrency);
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
      
        paymentCurrency.transferFrom(msg.sender, self, profilePrice);
        paymentCurrency.transfer(SAFE_HARBOUR, profilePrice);

        _userProfile = factory.createProfile(_avatar);
        profileByName[_avatar.name] = _userProfile;
        profileByOwner[_avatar.owner] = _userProfile; 

        return _userProfile; 
    }


    function notifyChangeOfConfig() external returns (bool _notified ){
        registry = IOpenRegister(registry.getAddress(RegisterRegistryKey));
        paymentCurrency = IERC20Metadata(registry.getAddress(gatewayPaymentCurrencyRegistryKey));
        owner = registry.getAddress(gatewayOwnerRegistryKey);
        admin = registry.getAddress(gatewayAdminRegistryKey);
        SAFE_HARBOUR = registry.getAddress(gatewaySafeHarbourRegistryKey);
        factory = IProfileFactory(registry.getAddress(gatewayProfileFactoryRegistryKey));
        return true; 
    }

    //========================================== Internal ==========================================================

    function setConfig(OpGatewayConfig memory config) internal returns (bool _configured) {
        registry = IOpenRegister(config.registry);
        paymentCurrency = IERC20Metadata(registry.getAddress(gatewayPaymentCurrencyRegistryKey));
        owner = registry.getAddress(gatewayOwnerRegistryKey);
        admin = registry.getAddress(gatewayAdminRegistryKey);
        SAFE_HARBOUR = registry.getAddress(gatewaySafeHarbourRegistryKey);
        factory = IProfileFactory(registry.getAddress(gatewayProfileFactoryRegistryKey));

        profilePrice = config.profilePrice; 
        return true; 
    }

}