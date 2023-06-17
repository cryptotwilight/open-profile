// SPDX-License-Identifier: APACHE 2.0
pragma solidity ^0.8.20;

// Version 1 

interface IOpenProfileRewardsPool {


    // name of this rewards pool 
    function getPoolName() view external returns (string memory _poolName);

    // distributable rewards
    function getAvailableApeCoinRewards() view external returns (uint256 _rewards);

    // recipients of ape coin rewards from pool 
    function getRecipients() view external returns (address [] memory _profiles);
    
    // Ape Coin protocol claimable rewards
    function getClaimableRewards() external returns (uint256 _claimableRewards);

    // action reward claim from ApeCoin protocol
    function claimApeCoinRewardsForCommunity() external returns (uint256 _claimed);
    // issue a given level of reward to a specific community member
    function issueApeCoinReward(address _communityMemberProfile, uint256 _amount) external returns (uint256 _amountRewarded);

    function grantPrincipalFunds(uint256 _amount) external returns (uint256 _principleBalance);

    function withdrawPrincipalFunds(uint256 _amount) external returns (bool _withdrawn);


    // disburse rewaards to your entire community 
    function disburseApeCoinRewards(uint256 _totalAmount) external returns (bool _rewardsDisbursed);

    function addRecipient(address _communityMemberProfile) external returns (bool _added);

    function removeRecipient(address _communityMemberProfile) external returns (bool _removed);

}