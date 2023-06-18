// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

// version 2

interface IApeCoinStakingProxy { 

    function getApeCoinStake( address _self) view external returns (uint256 _stakedTotal); 

    function withdrawSelfApeCoin(uint256 _amount)  external returns (bool _withdrawn);

    function depositSelfApeCoin(uint256 _amount)  external returns (bool _deposited);

    function claimSelfApeCoin() external returns (bool claimed);

    function setRewardsPool(address _rewardsPool) external returns (bool _rewardsPoolSet);

}