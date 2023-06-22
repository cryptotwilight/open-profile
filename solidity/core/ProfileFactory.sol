// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "https://github.com/Block-Star-Logic/open-version/blob/main/blockchain_ethereum/solidity/V1/interfaces/IOpenVersion.sol";
import "https://github.com/Block-Star-Logic/open-register/blob/main/blockchain_ethereum/solidity/V1/interfaces/IOpenRegister.sol";

import "../interfaces/IOpenProfileGateway.sol";
import "../interfaces/IApeCoinStakingProxy.sol";
import "../interfaces/IOpenProfileRewardsPool.sol";
import "../interfaces/IOpenProfile.sol";

import "../interfaces/IProfileFactory.sol";
import "../interfaces/IApeCoinStakingProxyFactory.sol";
import "../interfaces/IOpenProfileConsoleFactory.sol";
import "../interfaces/IOpenProfileRewardsPoolFactory.sol";

import "./OpenProfile.sol";


contract ProfileFactory is IProfileFactory, IOpenVersion {

    string constant name = "OP_PROFILE_FACTORY";
    uint256 constant version = 4; 

    string constant openProfileGatewayRegistryKey            = "OPEN_PROFILE_GATEWAY";
    string constant openProfileRewardsPoolFactoryRegistryKey = "OP_REWARDS_POOL_FACTORY";
    string constant openProfileConsoleFactoryRegistryKey     = "OP_CONSOLE_FACTORY";
    string constant apeCoinProxyFactoryRegistryKey           = "APE_COIN_STAKING_PROXY_FACTORY";
    string constant apeCoinRegistryKey                       = "APE_COIN";

    IOpenRegister registry; 
    IOpenProfileGateway gateway;
    IApeCoinStakingProxyFactory proxyFactory;
    IOpenProfileRewardsPoolFactory rewardsPoolFactory;
    IOpenProfileConsoleFactory consoleFactory; 
    

    mapping(address=>bool) isRecognizedAddress; 
    

    constructor(address _register) {
        registry            = IOpenRegister(_register);
        gateway             = IOpenProfileGateway(registry.getAddress(openProfileGatewayRegistryKey));
        proxyFactory        = IApeCoinStakingProxyFactory(registry.getAddress(apeCoinProxyFactoryRegistryKey));
        rewardsPoolFactory  = IOpenProfileRewardsPoolFactory(registry.getAddress(openProfileConsoleFactoryRegistryKey));
        consoleFactory      = IOpenProfileConsoleFactory(registry.getAddress(openProfileConsoleFactoryRegistryKey));
    }

    function getName() pure external returns (string memory _name) {
        return name;
    }

    function getVersion() pure external returns (uint256 _version) {
        return version; 
    }    

    function createProfile(Avatar memory _avatar) external returns (address _profile){
        doSecurity(); 

        address proxy_ = proxyFactory.createProxy(); 
        address rewardsPool_ = rewardsPoolFactory.createRewardsPool(_avatar.name, proxy_);
        address console_ = consoleFactory.createConsole(_avatar, rewardsPool_,  address(gateway));

        IApeCoinStakingProxy apeCoinStaking_ = IApeCoinStakingProxy (proxy_);
        apeCoinStaking_.setRewardsPool(rewardsPool_); 
        
        IOpenProfileRewardsPool opRewardsPool_ = IOpenProfileRewardsPool(rewardsPool_);
        opRewardsPool_.setConsole(console_);
        
        IOpenProfileConsole opConsole_ = IOpenProfileConsole(console_);
        
        OpenProfile profile_ = new OpenProfile(address(console_));
        _profile = address(profile_);
        opConsole_.setProfile(_profile);

        return _profile; 
    }

    function isRecognized(address _address) view external returns (bool _isRecognised) {
        return isRecognizedAddress[_address];
    }

    //=============================================== INTERNAL ===============================================

    function doSecurity() view internal returns (bool) {
        require(msg.sender == address(gateway), "gateway only");
        return true; 
    }
    
}