// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

interface IOpenProfileRewardsPoolFactory {

    function isRecognised(address _address) view external returns (bool _isRecognisedProxy);

    function createRewardsPool(string memory _poolName, address _apeCoinStakingProxy) external returns (address _rewardsPool);

}