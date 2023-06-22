// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

// version 1

interface IOpenProfileRewardsPoolFactory {

    function isRecognised(address _address) view external returns (bool _isRecognisedProxy);

    function createRewardsPool(string memory _poolName, address _apeCoinStakingProxy) external returns (address _rewardsPool);

}