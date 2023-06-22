// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

import "https://github.com/Block-Star-Logic/open-version/blob/main/blockchain_ethereum/solidity/V1/interfaces/IOpenVersion.sol";
import "https://github.com/Block-Star-Logic/open-register/blob/main/blockchain_ethereum/solidity/V1/interfaces/IOpenRegister.sol";

import "../interfaces/IOpenProfileRewardsPool.sol";
import "../interfaces/IApeCoinStakingProxy.sol";
import "../interfaces/IOpenProfileConsole.sol";


contract OpenProfileRewardsPool is IOpenProfileRewardsPool, IOpenVersion {

        string constant name = "OPEN_PROFILE_APECOIN_REWARDS_POOL";
        uint256 constant version = 4; 
        address self; 
  
        string constant opProfileFactoryRegistryKey = "OP_PROFILE_FACTORY"; 

        string poolName; 
        
        address [] allRecipients; 
        mapping(address=>bool) isCurrentRecipient; 
            
        IOpenRegister registry; 
        IERC20 apeCoin;
        IApeCoinStakingProxy apeCoinStaking; 
        IOpenProfileConsole console;  

        uint256 claimedRewards; // rewards claimed but not disbursed
        uint256 disbursedRewards; // rewards that have been disbursed 
        uint256 availableRewards; // rewards left claimed - disbursed
        uint256 principleFunds = 0; 

        bool isConsoleSet = false; 

        constructor(string memory _poolName, 
                            address _apeCoin,
                            address _apeCoinStaking, 
                            address _registry) {
            poolName        = _poolName; 
            apeCoin         = IERC20(_apeCoin);
            apeCoinStaking  = IApeCoinStakingProxy(_apeCoinStaking);
            registry        = IOpenRegister(_registry);

            self = address(this);
        }

        function getName() pure external returns (string memory _name) {
            return name;
        }

        function getVersion() pure external returns (uint256 _version) {
            return version; 
        }

        function getPoolName() view external returns (string memory _poolName) {
            return poolName; 
        }

        function getAvailableApeCoinRewards() view external returns (uint256 _rewards) {
            return claimedRewards;
        }

        function getRecipients() view external returns (address [] memory _profiles) {
            doInternalSecurity();
            _profiles = new address[](allRecipients.length);
            uint256 y = 0; 
            for(uint256 x = 0; x < allRecipients.length; x++){
                address recipient_ = allRecipients[x];
                if(isCurrentRecipient[recipient_]){
                    _profiles[y] = recipient_; 
                    y++;
                }
            }
            return _profiles; 
        }

        function getClaimableRewards() view external returns (uint256 _claimableRewards) {
            return getAvailableRewardsInternal();
        }

        function claimApeCoinRewardsForCommunity() external returns (uint256 _claimed) {
            _claimed = apeCoinStaking.getApeCoinStake(self);
            apeCoinStaking.claimSelfApeCoin();
            claimedRewards += _claimed; 
            return _claimed; 
        }

        function issueApeCoinReward(address _communityMemberProfile, uint256 _amount) external returns (uint256 _amountRewarded) {
            doInternalSecurity();
            require(claimedRewards >= _amount, "insufficient funds");
            apeCoin.transfer(_communityMemberProfile, _amount);
            return _amountRewarded; 
        }

        function grantPrincipalFunds(uint256 _amount) external returns (uint256 _principleBalance) {
            apeCoin.transferFrom(msg.sender, self, _amount);
            principleFunds += _amount; 
            apeCoin.transferFrom(msg.sender, self, _amount);
            apeCoin.approve(address(apeCoinStaking), _amount);
            apeCoinStaking.depositSelfApeCoin(_amount);
            return principleFunds; 
        }

        function withdrawPrincipalFunds(uint256 _amount) external returns (bool _withdrawn){
            doInternalSecurity();
            require(principleFunds >= _amount, "insufficient princple to withdraw");
            principleFunds -= _amount; 
            apeCoinStaking.withdrawSelfApeCoin(_amount);
            apeCoin.transfer(msg.sender, _amount);
            return true; 
        }


        // disburse rewaards to your entire community 
        function disburseApeCoinRewards(uint256 _totalAmount) external returns (bool _rewardsDisbursed) {
            doInternalSecurity();
            require(_totalAmount <= apeCoin.balanceOf(self), "insufficient balance");
            uint256 totalRecipients_ = getTotalRecipients(); 
            uint256 allocation_ = claimedRewards / totalRecipients_; 
            for(uint256 x = 0; x < allRecipients.length; x++) {
                address recipient_ = allRecipients[x]; 
                if(isCurrentRecipient[recipient_]){
                    apeCoin.transfer(recipient_, allocation_);
                }
            }
            return true; 
        }

        function addRecipient(address _communityMemberProfile) external returns (bool _added){
            doInternalSecurity();
            require(!isCurrentRecipient[_communityMemberProfile], " is already recipient");
            isCurrentRecipient[_communityMemberProfile] = true; 
            allRecipients.push(_communityMemberProfile);
            return true; 
        }

        function removeRecipient(address _communityMemberProfile) external returns (bool _removed) {
            doInternalSecurity();
            require(isCurrentRecipient[_communityMemberProfile], " not recipient" );
            isCurrentRecipient[_communityMemberProfile] = false; 
            return true; 
        }

        function setConsole(address _console) external returns (bool _set) {
            require(msg.sender == registry.getAddress(opProfileFactoryRegistryKey), "factory only " );
            require(!isConsoleSet, "console already set");
            console = IOpenProfileConsole(_console);
            isConsoleSet = true; 
            return isConsoleSet; 
        }

        // ============================ INTERNAL =============================================================================

        function getAvailableRewardsInternal() view internal returns (uint256 _amount) {
            return apeCoinStaking.getApeCoinStake(self);
        }

        function doInternalSecurity() view internal returns (bool) {
            require(msg.sender == console.getAvatar().owner, " owner only ");
            return true;
        }

        function getTotalRecipients() view internal returns (uint256 _total) {
              for(uint256 x = 0; x < allRecipients.length; x++) {
                address recipient_ = allRecipients[x]; 
                if(isCurrentRecipient[recipient_]){
                        _total++;                
                }
            }
        }
}