// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "../interfaces/IVersioning.sol";
import "../interfaces/IRegister.sol";
import "../interfaces/IOpenProfileConsoleFactory.sol";

import "./OpenProfileConsole.sol";

contract OpenProfileConsoleFactory is IVersioning, IOpenProfileConsoleFactory {

    string constant name = "OP_REWARDS_POOL_FACTORY";
    uint256 constant version = 1; 

    IRegister registry; 
    string constant opProfileFactory                = "OP_PROFILE_FACTORY"; 
    string constant apeCoinRegistryKey              = "APE_COIN";


    mapping(address=>bool) isRecognisedAddress; 

    constructor(address _register) {
        registry = IRegister(_register);
    }

    function getName() pure external returns (string memory _name) {
        return name;
    }

    function getVersion() pure external returns (uint256 _version) {
        return version; 
    }

    function isRecognised(address _address) view external returns (bool _isRecognised){
        return isRecognisedAddress[_address];
    }

    function createConsole(Avatar memory _avatar, address _rewardsPool, address _directory) external returns (address _console){
        doSecurity(); 
        OpenProfileConsole console_        = new OpenProfileConsole(_avatar, _rewardsPool,  _directory);
        _console = address(console_);
        isRecognisedAddress[_console] = true; 
        return _console; 
    }

    function doSecurity() view internal returns (bool) {
        require(msg.sender == registry.getAddress(opProfileFactory), "factory only");
        return true;
    }
}