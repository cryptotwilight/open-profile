// SPDX-License-Identifier: APACHE 2.0
pragma solidity ^0.8.20;

import {SocialRequest, MediaMetaData, Meeting, Avatar, Social} from "./IOpenProfileConsole.sol";

interface IOpenProfile {


    function getAvatar() view external returns (Avatar memory _avatar);

    function getSocials() view external returns(Social [] memory socials);

    function getConnection(string memory _name) view external returns (address _profile);

    // CONNECTIONS, SUPPORTERS, FOLLOWERS,
    function getCommunityCount(string memory _countType) view external returns (uint256 _count);

    function getConnections() view external returns (address [] memory connections);
    
    function getFollowers () view external returns (address [] memory _followers);

    function getSupporters() view external returns (address [] memory _supporters);

    function getMedia() view external returns (MediaMetaData [] memory _media);
    
    function getMeetings() view external returns (Meeting [] memory _meetings);

    function getRewardPool() view external returns (address rewardsPool);

    function getConsole() view external returns (address _console);

    //========================= External Write ============================================

    function getRequests() view external returns (SocialRequest [] memory _requests);

        //======================== Followers =============================================

    function follow() external returns (bool _followed);

    function unfollow() external returns (bool _unfollowed);

        //======================== Supporters =============================================

    function support(uint256 _contribution, address _erc20) payable external returns (bool _followed) ;

    function rescindSupport(address _supporter) external returns (bool _supportRescinded);    

        //======================== Connections =============================================

    function requestConnection() external returns (bool _requested);

    function cancelConnectionRequest() external returns (bool _cancelled);

    function removeConnection() external returns (bool _connectionRemoved);

        //======================== Meetings =============================================

    function requestMeeting(uint256 _meetingTime) external returns (uint256 _meetingRequestId);

    function cancelMeetingRequest(uint256 _meetingRequestId) external returns(bool _cancelled);

    function cancelMeeting(uint256 _meetingId) external returns (bool _cancelled);

        //======================== Media Share =============================================

    function requestMediaShare(MediaMetaData [] memory metadata ) external returns (uint256 _uniqueShareRequestCount);

    function cancelMediaShareRequest(uint256 [] memory _metadataIds) external returns (uint256 _cancelledMediaShareRequestCount);

}

