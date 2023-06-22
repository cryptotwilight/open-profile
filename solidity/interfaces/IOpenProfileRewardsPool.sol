// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

// version 1

interface IOpenProfileRewardsPool { 

        function getAvailableApeCoinRewards() view external returns (uint256 _rewards);

        function getRecipients() view external returns (address [] memory _profiles);

        function getClaimableRewards() view external returns (uint256 _claimableRewards);

        function claimApeCoinRewardsForCommunity() external returns (uint256 _claimed) ;

        function issueApeCoinReward(address _communityMemberProfile, uint256 _amount) external returns (uint256 _amountRewarded) ;

        function grantPrincipalFunds(uint256 _amount) external returns (uint256 _principleBalance);

        function withdrawPrincipalFunds(uint256 _amount) external returns (bool _withdrawn);

        // disburse rewaards to your entire community 
        function disburseApeCoinRewards(uint256 _totalAmount) external returns (bool _rewardsDisbursed);

        function addRecipient(address _communityMemberProfile) external returns (bool _added);

        function removeRecipient(address _communityMemberProfile) external returns (bool _removed);

        function setConsole(address _console) external returns (bool _set);
}