// SPDX-License-Identifier: APACHE 2.0
pragma solidity ^0.8.20;

// version 1

struct MediaMetaData {
    uint256 id; 
    string mediaCid; 
    string mediaType; 
    string mediaMetadataCid;
}

struct Social {
    uint256 id; 
    string name; 
    string link; 
}

struct Avatar {
    uint256 id; 
    address owner; 
    string name; 
    string imageCid; 
}

struct Meeting {
    uint256 id; 
    address [] participants; 
    uint256 startTime; 
    uint256 duration; 
}

struct SocialRequest {
    uint256 id; 
    address requestor; 
    string requestType; 

}


interface IOpenProfileConsole {

    function getAvatar() view external returns (Avatar memory _avatar);

    function getSocials() view external returns (Social [] memory _socials);

    function getMedia() view external returns (MediaMetaData [] memory _media);

    function getMeetings() view external returns (Meeting [] memory _meetings);

    function getRewardsPool() view external returns (address rewardsPool);

    // CONNECTIONS, SUPPORTERS, FOLLOWERS 
    function getProfileList(string memory _community) view external returns (address [] memory _profileList);

    // CONNECTIONS, SUPPORTERS, FOLLOWERS 
    function getCommunityCount(string memory _community) view external returns (uint256 _count);

    function getSocialRequests() view external returns (SocialRequest [] memory _requests);


    function isCommunity(address _member, string memory _type) view external returns (bool _isCommunity);

    function addCommunity(address _member, string memory _type) external returns (bool _added);

    function removeCommunity(address _member, string memory _type) external returns (bool _removed);


    function acceptSocialRequest(uint256 [] memory socialRequestIds) external returns (bool _accepted);

    function rejectSocialRequest(uint256 [] memory socialRequestIds) external returns (bool _accepted);


    function shareMedia(uint256 [] memory _mediaIds, address [] memory _connections) external returns (bool _shared); 

    function addMedia(MediaMetaData [] memory _media) external returns (uint256 _addedCount);

    function removeMedia(uint256 [] memory _mediaIds) external returns (uint256 _removedMediaCount);


    function getDirectory() view external returns (address _directory);

    function getIndex() external returns (uint256 _index);

    // MEETING_DURATION
    function getUINTProperty(string memory _property) view external returns (uint256 _value);

    // PAYMENT_CURRENCY
    function getAddressProperty(string memory _property) view external returns (address _address);

}