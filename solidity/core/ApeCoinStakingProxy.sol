// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;


import "https://github.com/HorizenLabs/ape-staking-public/blob/6b86a6d92153455fe9f33b0bda16e4141099fc7d/contracts/ApeCoinStaking.sol";

import "https://github.com/Block-Star-Logic/open-register/blob/main/blockchain_ethereum/solidity/V1/interfaces/IOpenRegister.sol";
import "https://github.com/Block-Star-Logic/open-version/blob/main/blockchain_ethereum/solidity/V1/interfaces/IOpenVersion.sol";

import "../interfaces/IApeCoinStakingProxy.sol";


contract ApeCoinStakingProxy is IApeCoinStakingProxy, IOpenVersion { 

    string constant name = "APE_COIN_STAKING_PROXY";
    uint256 constant version = 3; 

    string constant apeCoinStakingRegistryKey   = "APE_COIN_STAKING";
    string constant apeCoinRegistryKey          = "APE_COIN"; 
    string constant openProfileFactoryRegistryKey = "OPEN_PROFILE_FACTORY";

    ApeCoinStaking apeCoinStaking; 
    IERC20 apeCoin; 
    address rewardsPool;
    address self; 
    bool rewardsPoolSet = false; 
    IOpenRegister registry; 

    constructor( address _registry) {
        registry = IOpenRegister(_registry); 
        apeCoinStaking = ApeCoinStaking(registry.getAddress(apeCoinStakingRegistryKey)); 
        apeCoin = IERC20(registry.getAddress(apeCoinRegistryKey));
        self = address(this); 
    }
    function getName() pure external returns (string memory _name) {
        return name;
    }

    function getVersion() pure external returns (uint256 _version) {
        return version; 
    }

    function getApeCoinStake( address _self) view external returns (uint256 _stakedTotal){
        return apeCoinStaking.getApeCoinStake(_self).unclaimed;
    }

    function withdrawSelfApeCoin(uint256 _amount)  external returns (bool _withdrawn){
        require(msg.sender == rewardsPool, "reward pool only");
        apeCoinStaking.withdrawSelfApeCoin(_amount);
        apeCoin.transfer(rewardsPool, _amount);
        return true; 
    }

    function depositSelfApeCoin(uint256 _amount)  external returns (bool _deposited){
        require(msg.sender == rewardsPool, "reward pool only");
        apeCoinStaking.depositSelfApeCoin(_amount);
        return true; 
    }

    function claimSelfApeCoin() external returns (bool claimed){
        apeCoinStaking.claimSelfApeCoin(); 
        apeCoin.transfer(rewardsPool, apeCoin.balanceOf(self));
        return true; 
    }

    function setRewardsPool(address _rewardsPool) external returns (bool _rewardsPoolSet){
        require(!rewardsPoolSet, "rewards pool already set");
        require(msg.sender == registry.getAddress(openProfileFactoryRegistryKey), "factory only");
        rewardsPool = _rewardsPool; 
        rewardsPoolSet =  true; 
        return true; 
    }

    //======================================== INTERNAL =================================================

    function doSecurity() view internal returns (bool) {
        require(msg.sender == rewardsPool, "reward pool only");
        return true; 
    }


}