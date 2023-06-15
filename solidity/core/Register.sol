// SPDX-License-Identifier: APACHE 2.0
pragma solidity ^0.8.20;


import "../interfaces/IRegister.sol";
import "../interfaces/IVersioning.sol";

contract Register is IRegister, IVersioning {

    string constant name = "REGISTER";
    uint256 constant version = 1; 

    address admin; 

    mapping(string=>address) addressByName; 
    mapping(address=>string) nameByAddress; 
    mapping(address=>uint256) versionByAddress; 

    constructor(address _admin) {
        admin = _admin; 
    }

    function getAdmin() view external returns (address _admin) {
        return admin; 
    }

    function getName() pure  external returns (string memory _name){
        return name;
    }

    function getVersion() pure external returns (uint256 _version){
        return version; 
    }

    function getAddress(string memory _name) view external returns (address _address){
        return addressByName[_name];
    }

    function getName(address _address) view external returns (string memory _name){
        return nameByAddress[_address];
    }

    function addVersioningAddress(address _address) external returns (bool _added) {
        doSecurity();     
        IVersioning v_ = IVersioning(_address);
        addAddressInternal(_address, v_.getName(), v_.getVersion());
        return true; 
    }

    function addAddress(address _address, string memory _name, uint256 _version) external returns (bool _added) {
        doSecurity();     
        addAddressInternal(_address, _name, _version);
        return true; 
    }

    function removeAddress(address _address) external returns (bool _removed) { 
        doSecurity();     
         delete addressByName[nameByAddress[_address]];         
         delete versionByAddress[_address];
         delete nameByAddress[_address];
         return true; 
    }


    // ============================= INTERNAL ===========================================

    function doSecurity() view internal returns (bool) {
        require(msg.sender == admin, "admin only");
        return true; 
    }

    function addAddressInternal(address _address, string memory _name, uint256 _version) internal returns (bool) {
        addressByName[_name] = _address;
        nameByAddress[_address] = _name; 
        versionByAddress[_address] = _version; 
        return true; 
    }

}