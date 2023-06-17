// SPDX-License-Identifier: APACHE 2.0
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../interfaces/IVersioning.sol";
import "../interfaces/IOpenProfile.sol";
import "../interfaces/IOpenProfileConsole.sol";
import "../interfaces/IOpenDirectory.sol";

contract OpenProfile is IOpenProfile, IVersioning {


    string constant name = "OPEN_PROFILE"; 
    uint256 constant version = 3;   
    address self; 

    IOpenProfileConsole console;    
    IOpenDirectory directory;     

    mapping(string=>bool) knownCids; 
    mapping(address=>mapping(uint256=>bool)) isKnownsharedMediaByAddress;
    mapping(address=>mapping(uint256=>bool)) acceptedSharedMediaByAddress; 

    uint256 [] pendingSocialRequests; 
    mapping(uint256=>bool) isClosedSocialRequestById; 
    mapping(uint256=>SocialRequest) socialRequestById; 

    mapping(uint256=>address) connectRequestProfileBySocialRequestId; 

    mapping(address=>mapping(uint256=>MediaMetaData)) mediaMetadataByIdByAddress; 
    mapping(uint256=>address) metadataOwnerByMetadataId; 
    
    mapping(uint256=>bool) isBookedByMeetingTime; 
    mapping(uint256=>Meeting) meetingById; 
    mapping(uint256=>Meeting) meetingBySocialRequestId;

    mapping(address=>bool) isSupporter; 
    mapping(address=>mapping(string=>bool)) hasOutstandingRequestByAddress; 
    mapping(string=>bool) knownCid;
    
    mapping(string=>address) connectionProfileByName; 
    mapping(address=>uint256) socialRequestIdByConnectionRequestor;

    mapping(uint256=>MediaMetaData) mediaMetaDataById; 
    mapping(uint256=>uint256) socialRequestIdByMetadataMediaId; 

    constructor(address _consoleAddress) {
       console = IOpenProfileConsole(_consoleAddress); 
       directory = IOpenDirectory(console.getDirectory());
       self = address(this); 
    }

    function getName() pure external returns (string memory _name) {
        return name;
    }

    function getVersion() pure external returns (uint256 _version) {
        return version; 
    }

    function getConsole() view external returns (address _console) {
        return address(console); 
    }

    function getAvatar() view external returns (Avatar memory _avatar){
        return console.getAvatar(); 
    }

    function getSocials() view external returns (Social [] memory _socials){
        return console.getSocials(); 
    }

    function getMedia() view external returns (MediaMetaData [] memory _media) {
        return console.getMedia(); 
    }

    function getMeetings() view external returns (Meeting [] memory _meetings) {
        return console.getMeetings();
    }

    function getConnections() view external returns (address [] memory connections) {
        return console.getProfileList("CONNECTIONS");
    }

    function getFollowers () view external returns (address [] memory _followers) {
        return console.getProfileList("FOLLOWERS"); 
    }

    function getSupporters() view external returns (address [] memory _supporters) {
        return console.getProfileList("SUPPORTERS");
    }

    function getRewardPool() view external returns (address rewardsPool) {
        return console.getRewardsPool(); 
    }

    function getPendingSocialRequests() view external returns (SocialRequest [] memory _requests) {
        _requests = new SocialRequest[](pendingSocialRequests.length);
        for(uint256 x = 0; x < _requests.length; x++) {
            uint256 requestId_ =pendingSocialRequests[x]; 
            if(!isClosedSocialRequestById[requestId_]){
                _requests[x] = socialRequestById[requestId_];
            }
        }
    }

    function closeSocialRequests(uint256 [] memory _socialRequestIds) external returns (uint256 _closedCount) {
        for(uint256 x = 0; x < _socialRequestIds.length; x++) {
            uint256 requestId_ = _socialRequestIds[x];
            _closedCount += closeSocialRequestInternal(requestId_);
        }
        return _closedCount; 
    }


    function getConnection(string memory _name) view external returns (address _profile){
        return connectionProfileByName[_name];
    }

    // CONNECTIONS, SUPPORTERS, FOLLOWERS,
    function getCommunityCount(string memory _communityType) view external returns (uint256 _count){
       return console.getCommunityCount(_communityType);
    }

    function emptyFundsFromProfile(address _erc20) external returns (uint256 _amountEmptied) {
        IERC20Metadata erc20_ = IERC20Metadata(_erc20);
        _amountEmptied = erc20_.balanceOf(self);
        erc20_.transfer( console.getAvatar().owner, _amountEmptied);
        return _amountEmptied; 
    }

    function pullConnectProfile(uint256 _socialRequestId) view external returns (address _connectProfile) {
        return connectRequestProfileBySocialRequestId[_socialRequestId];
    }

    function pullMedia(uint256 _socialRequestId) view external returns (MediaMetaData memory _media) {
        return mediaMetaDataById[_socialRequestId];
    }

    function pullMeetings(uint256 _socialRequestId) view external returns (Meeting memory _meeting) {
        return meetingById[_socialRequestId]; 
    }



    //========================= External Write ============================================

    function follow() external returns (bool _followed) { 
        doExternalSecurity(); 
        console.addCommunity(resolve(msg.sender), "FOLLOWER");
        return true; 
    }

    function unfollow() external returns (bool _unfollowed) {
        require(console.isCommunity(msg.sender, "FOLLOWER"), "not follower");
        console.removeCommunity(resolve(msg.sender), "FOLLOWER");
        return true; 
    }

    function support(uint256 _contribution, address _erc20) payable external returns (bool _followed) { 
        doExternalSecurity(); 
        takePayment(_contribution, _erc20); 
        return console.addCommunity(resolve(msg.sender), "SUPPORTER");        
    }

    function rescindSupport(address _supporter) external returns (bool _supportRescinded) {
        require(console.isCommunity(msg.sender, "SUPPORTER"), " active supporters only ");
        require(msg.sender == _supporter || msg.sender == console.getAvatar().owner, "supporter or owner only");
        return console.removeCommunity(resolve(_supporter), "SUPPORTER"); 

    }

    function requestConnection() external returns (bool _requested){
        require((!console.isCommunity(msg.sender, "CONNECTION") && !hasOutstandingRequestByAddress[msg.sender]["CONNECT"]), "connected or already has outstanding request");
    
        SocialRequest memory socialRequest_ = addSocialRequest(msg.sender, "CONNECT_REQUEST" );
        connectRequestProfileBySocialRequestId[socialRequest_.id] = resolveToProfile(msg.sender);
        socialRequestIdByConnectionRequestor[msg.sender] = socialRequest_.id;   
        hasOutstandingRequestByAddress[msg.sender]["CONNECT"] = true; 
        return true; 
    }

    function cancelConnectionRequest() external returns (bool _cancelled) {
        require( hasOutstandingRequestByAddress[msg.sender]["CONNECT"], "no request found" );
        uint256 socialRequestId = socialRequestIdByConnectionRequestor[msg.sender];
        delete connectRequestProfileBySocialRequestId[socialRequestId];
        delete hasOutstandingRequestByAddress[msg.sender]["CONNECT"]; 
        closeSocialRequestInternal(socialRequestId);
        return true; 
    }

    function removeConnection() external returns (bool _connectionRemoved) {
        require(console.isCommunity(msg.sender, "CONNECTION"), "not connection");
        console.removeCommunity(resolve(msg.sender), "CONNECTION");
        return true; 
    }


    function requestMeeting(uint256 _meetingTime) external returns (uint256 _meetingRequestId){
        doExternalSecurity(); 
        require(!isBookedByMeetingTime[_meetingTime], " already booked ");
        address [] memory participants_ = new address[](2);
        participants_[0] = msg.sender; 
        participants_[1] = console.getAvatar().owner;
        SocialRequest memory socialRequest_ = addSocialRequest(msg.sender, "MEETING_REQUEST" );
        Meeting memory meeting_ = Meeting ({
                                            id : socialRequest_.id,
                                            participants : participants_,
                                            startTime : _meetingTime, 
                                            duration : console.getUINTProperty("MEETING_DURATION")
                                        });
        
        meetingBySocialRequestId[socialRequest_.id] = meeting_; 
        return meeting_.id; 
    }   

    function cancelMeetingRequest(uint256 _meetingRequestId) external returns(bool _cancelled) {
        Meeting memory meeting_ = meetingBySocialRequestId[_meetingRequestId];
        require(msg.sender == meeting_.participants[0] || msg.sender == meeting_.participants[1], "unknown participant"); 
        delete meetingBySocialRequestId[_meetingRequestId];
        closeSocialRequestInternal(_meetingRequestId);
        return true; 

    }  


    function requestMediaShare(MediaMetaData memory _metadata ) external returns (bool _requested){
        doExternalSecurity(); 
        
        if(!isKnownsharedMediaByAddress[msg.sender][_metadata.id]
            && !knownCid[_metadata.mediaCid] 
            && !knownCid[_metadata.mediaMetadataCid]){

            knownCid[_metadata.mediaCid] = true; 
            knownCid[_metadata.mediaMetadataCid] = true; 
            isKnownsharedMediaByAddress[msg.sender][_metadata.id] = true; 
            mediaMetaDataById[_metadata.id] = _metadata; 
            
            SocialRequest memory socialRequest_ = addSocialRequest(msg.sender, "MEDIA_SHARE_REQUEST" );
            socialRequestIdByMetadataMediaId[_metadata.id] = socialRequest_.id; 
        }
        
        return true;
    }

    function cancelMediaShareRequest(uint256 [] memory _metadataIds) external returns (uint256 _cancelledCount) {
        for(uint256 x = 0; x < _metadataIds.length; x++) {
            uint256 metadataId_ = _metadataIds[x];
            MediaMetaData memory metadata_ = mediaMetadataByIdByAddress[metadataOwnerByMetadataId[metadataId_]][metadataId_];
            if(isKnownsharedMediaByAddress[msg.sender][metadata_.id]){
                delete mediaMetaDataById[metadataId_];
                closeSocialRequestInternal(socialRequestIdByMetadataMediaId[metadataId_]);
                _cancelledCount; 
            }
        }
        return _cancelledCount;
    }
    //========================= INTERNAL ========================================================

    function closeSocialRequestInternal(uint256 _requestId) internal returns (uint256 _closed) {
         if(!isClosedSocialRequestById[_requestId]){ 
                isClosedSocialRequestById[_requestId] = true; 
                return 1; 
        }
        return 0; 
    }

    function takePayment(uint256 _contribution, address _erc20) internal returns (bool _paid) {
        IERC20Metadata erc20_ = IERC20Metadata(_erc20);
        erc20_.transferFrom(msg.sender, self, _contribution);
        erc20_.transfer(console.getAvatar().owner, _contribution);
        return true; 
    }

    function resolveToProfile(address _user) view internal returns (address _profile){
        return directory.getProfile(_user);
    }
    
    function addSocialRequest(address _requestor, string memory _type) internal returns (SocialRequest memory _socialRequest) {
        _socialRequest = SocialRequest({
                                        id : console.getIndex(), 
                                        requestor : _requestor,  
                                        requestType : _type
                                    });
        socialRequestById[_socialRequest.id] = _socialRequest; 
        pendingSocialRequests.push(_socialRequest.id);  
        return _socialRequest;    
    }

    function resolve( address _user) view internal returns (address _profile) {
        return directory.getProfile(_user);
    }

    function doExternalSecurity() view internal returns (bool) {
        require(!console.isBarred(msg.sender), "user not allowed");
        return true; 
    }
   
    function doInternalSecurity() view internal returns (bool) {
        require(console.getAvatar().owner == msg.sender, "owner only");
        return true; 
    }

    function isEqual(string memory a, string memory b) pure internal returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

}