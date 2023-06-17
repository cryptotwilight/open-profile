// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


import "https://github.com/HorizenLabs/ape-staking-public/blob/6b86a6d92153455fe9f33b0bda16e4141099fc7d/contracts/ApeCoinStaking.sol";


import "../interfaces/IApeCoinStakingProxy.sol";

contract ApeCoinStakingProxy is IApeCoinStakingProxy { 

    ApeCoinStaking apeCoinStaking; 
    IERC20 apeCoin; 
    address rewardPool;
    address self; 

    constructor( ApeCoinStaking _apeCoinStaking,
                 address _apeCoin, 
                 address _rewardPool) {
        apeCoinStaking = _apeCoinStaking; 
        apeCoin = IERC20(_apeCoin);
        rewardPool = _rewardPool; 
        self = address(this);
    }


    function getApeCoinStake( address _self) view external returns (uint256 _stakedTotal){
        return apeCoinStaking.getApeCoinStake(_self).unclaimed;
    }

    function withdrawSelfApeCoin(uint256 _amount)  external returns (bool _withdrawn){
        require(msg.sender == rewardPool, "reward pool only");
        apeCoinStaking.withdrawSelfApeCoin(_amount);
        apeCoin.transfer(rewardPool, _amount);
        return true; 
    }

    function depositSelfApeCoin(uint256 _amount)  external returns (bool _deposited){
        require(msg.sender == rewardPool, "reward pool only");
        apeCoinStaking.depositSelfApeCoin(_amount);
        return true; 
    }

    function claimSelfApeCoin() external returns (bool claimed){
        apeCoinStaking.claimSelfApeCoin(); 
        apeCoin.transfer(rewardPool, apeCoin.balanceOf(self));
        return true; 
    }

}