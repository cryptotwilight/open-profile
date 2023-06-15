// SPDX-License-Identifier: APACHE 2.0
pragma solidity ^0.8.20;
import "../interfaces/IVersioning.sol";
import "../interfaces/IOpenProfileConsole.sol";
import "../interfaces/IOpenDirectory.sol";

contract OpenProfileConsole is IOpenProfileConsole, IVersioning {
    

    string constant name = "OPEN_PROFILE_CONSOLE";
    uint256 constant  version = 1;

    uint256 uniqueIndex; 

    IOpenDirectory directory; 
    Avatar avatar; 

    address rewardsPool; 

    string [] socialNames;
    mapping(string=>bool)  knownSocial; 
    mapping(string=>Social) socialsByName; 

    uint256 [] mediaIds; 
    mapping(uint256=>MediaMetaData) mediaMetaDataById;

    mapping(address=>mapping(string=>bool)) isCommunityByTypeByProfileAddress; 
    mapping(address=>string) communityTypeByProfileAddress; 

    uint256 [] socialRequestIds; 
    mapping(uint256=>SocialRequest) socialRequestById; 

    uint256 [] meetingIds; 
    mapping(uint256=>Meeting) meetingById; 

    mapping(string=>address[]) profilesByListType;

    mapping(string=>uint256) uINTProperties; 

    mapping(string=>address) addressProperties; 

    constructor(Avatar memory _avatar, address _directoryAddress) {
        avatar = _avatar; 
        directory = IOpenDirectory(_directoryAddress);
        uniqueIndex = block.timestamp; 
    }

    function getName() pure external returns (string memory _name) {
        return name;
    }

    function getVersion() pure external returns (uint256 _version) {
        return version; 
    }

    function getAvatar() view external returns (Avatar memory _avatar){
        return avatar; 
    }

    function getSocials() view external returns (Social [] memory _socials){
        _socials = new Social[](socialNames.length);
        for(uint256 x = 0; x <_socials.length; x++) {
            string memory name_ = socialNames[x];
            _socials[x] = socialsByName[name_];
        }
        return _socials; 
    }

    function getMedia() view external returns (MediaMetaData [] memory _media){
        _media = new MediaMetaData[](mediaIds.length);
        for(uint256 x = 0; x < mediaIds.length; x++) {
            _media[x] = mediaMetaDataById[mediaIds[x]];
        }        
        return _media; 
    }

    function getMeetings() view external returns (Meeting [] memory _meetings) {
        _meetings = new Meeting[](meetingIds.length);
        for(uint256 x = 0; x < meetingIds.length; x++) {
            _meetings[x] = meetingById[meetingIds[x]];
        }        
        return _meetings;
    }

    function getRewardsPool() view external returns (address rewardsPool){
        return rewardsPool; 
    }

    // CONNECTIONS, SUPPORTERS, FOLLOWERS 
    function getProfileList(string memory _community) view external returns (address [] memory _profileList){
        return profilesByListType[_community];
    }

    // CONNECTIONS, SUPPORTERS, FOLLOWERS 
    function getCommunityCount(string memory _community) view external returns (uint256 _count){
        return profilesByListType[_community].length;
    }

    function getSocialRequests() view external returns (SocialRequest [] memory _requests){
        _requests = new SocialRequest[](socialRequestIds.length);
        for(uint256 x = 0; x < _requests.length; x++) {
            _requests[x] = socialRequestById[socialRequestIds[x]];
        }
        return _requests; 
    }

    function isCommunity(address _member, string memory _type) view external returns (bool _isCommunity){
        address profile_ = resolveToProfile(_member);
        return isCommunityByTypeByProfileAddress[profile_][_type];
    }

    function addCommunity(address _member, string memory _type) external returns (bool _added){
        doInternalSecurity(); 
        address profile_ = resolveToProfile(_member);
        require(!isCommunityByTypeByProfileAddress[profile_][_type], "already part of community");
        isCommunityByTypeByProfileAddress[profile_][_type] = true; 
        communityTypeByProfileAddress[profile_] = _type; 
        profilesByListType[_type].push(profile_);
        return true; 
    }

    function removeCommunity(address _member, string memory _type) external returns (bool _removed){
        doInternalSecurity(); 
        address profile_ = resolveToProfile(_member);
        require(isCommunityByTypeByProfileAddress[profile_][_type], "unknown community / member");
        delete isCommunityByTypeByProfileAddress[profile_][_type]; 
        delete communityTypeByProfileAddress[profile_]; 
        //profilesByListType[_type].push(profile_); // remove library
        return true; 
    }

    function acceptSocialRequest(uint256 [] memory socialRequestIds) external returns (bool _accepted){

    }

    function rejectSocialRequest(uint256 [] memory socialRequestIds) external returns (bool _accepted){

    }

    function shareMedia(uint256 [] memory _mediaIds, address [] memory _connections) external returns (bool _shared){

    } 

    function addMedia(MediaMetaData [] memory _media) external returns (uint256 _addedCount){

    }

    function removeMedia(uint256 [] memory _mediaIds) external returns (uint256 _removedMediaCount){

    }
    
    function addSocial(string memory _name, string memory _link)  external returns (bool _added) {
        doInternalSecurity();
        require(!knownSocial[name], "already added");
        Social memory social_ = Social({
                                        id : this.getIndex(),
                                        name : _name, 
                                        link : _link 
                                        });
        socialsByName[_name] = social_; 
        socialNames.push(_name);
        knownSocial[_name] = true;
        return true;  
    }

    function removeSocial(string memory _name) external returns (bool _removed) {
        doInternalSecurity();
        require(knownSocial[_name], "unknown social");
    }

    function getDirectory() view external returns (address _directory){
        return address(_directory);
    }

    function getIndex() external returns (uint256 _index){
        return uniqueIndex++;
    }

    function getUINTProperty(string memory _property) view external returns (uint256 _value){
        return uINTProperties[_property];
    }

    function setUINTProperty(string memory _property, uint256 _value)  external returns (bool _set) {
        doInternalSecurity(); 
        uINTProperties[_property] = _value; 
        return true;
    }

    function getAddressProperty(string memory _property) view external returns (address _value) {
        return addressProperties[_property];
    }

    function setAddressProperty(string memory _property, address _address) external returns (bool _set) {
        doInternalSecurity(); 
        addressProperties[_property] = _address; 
        return true; 
    }

    //=========================== INTERNAL ==============================================

    function doInternalSecurity() view internal returns (bool) {
        require(msg.sender == avatar.owner, " owner only ");
        return true;
    }

    function resolveToProfile( address _user) view internal returns (address _profile) {
        return directory.getProfile(_user);
    }
}
