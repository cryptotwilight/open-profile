// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "https://github.com/Block-Star-Logic/open-version/blob/main/blockchain_ethereum/solidity/V1/interfaces/IOpenVersion.sol";
import "https://github.com/Block-Star-Logic/open-register/blob/main/blockchain_ethereum/solidity/V1/interfaces/IOpenRegister.sol";

import "../interfaces/IOpenProfileRewardsPoolFactory.sol";

import "./OpenProfileRewardsPool.sol";



contract OpenProfileRewardsPoolFactory is IOpenVersion, IOpenProfileRewardsPoolFactory {

    string constant name = "OP_REWARDS_POOL_FACTORY";
    uint256 constant version = 2; 

    IOpenRegister registry; 
    string constant opProfileFactory                = "OP_PROFILE_FACTORY"; 
    string constant apeCoinRegistryKey              = "APE_COIN";


    mapping(address=>bool) isRecognisedAddress; 

    constructor(address _register) {
        registry = IOpenRegister(_register);
    }

    function getName() pure external returns (string memory _name) {
        return name;
    }

    function getVersion() pure external returns (uint256 _version) {
        return version; 
    }

    function isRecognised(address _address) view external returns (bool _isRecognised){
        return isRecognisedAddress[_address];
    }

    function createRewardsPool(string memory _poolName, address _apeCoinStakingProxy) external returns (address _rewardsPool){
        doSecurity(); 
        OpenProfileRewardsPool rewardsPool_ = new OpenProfileRewardsPool(_poolName, registry.getAddress(apeCoinRegistryKey), _apeCoinStakingProxy, address(registry));
        _rewardsPool = address(rewardsPool_);
        isRecognisedAddress[_rewardsPool] = true; 
        return _rewardsPool; 
    }

    function doSecurity() view internal returns (bool) {
        require(msg.sender == registry.getAddress(opProfileFactory), "factory only");
        return true;
    }
}