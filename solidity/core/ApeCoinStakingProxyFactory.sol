// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "../interfaces/IVersioning.sol";
import "../interfaces/IApeCoinStakingProxyFactory.sol";
import "../interfaces/IRegister.sol";
import "./ApeCoinStakingProxy.sol";



contract ApeCoinStakingProxyFactory is IVersioning, IApeCoinStakingProxyFactory {

    string constant name = "APE_COIN_STAKING_PROXY_FACTORY";
    uint256 constant version = 1; 

    IRegister registry; 
    string constant opProfileFactory = "OP_PROFILE_FACTORY"; 

    mapping(address=>bool) recognisedApeCoinStakingProxy; 

    constructor(address _register) {
        registry = IRegister(_register);
    }

    function getName() pure external returns (string memory _name) {
        return name;
    }

    function getVersion() pure external returns (uint256 _version) {
        return version; 
    }

    function isRecognisedProxy(address _address) view external returns (bool _isRecognisedProxy){
        return recognisedApeCoinStakingProxy[_address];
    }

    function createProxy() external returns (address _proxy){
        doSecurity(); 
        ApeCoinStakingProxy proxy_ = new ApeCoinStakingProxy(address(registry));
        _proxy = address(proxy_);
        recognisedApeCoinStakingProxy[_proxy] = true; 
        return _proxy; 
    }


    function doSecurity() view internal returns (bool) {
        require(msg.sender == registry.getAddress(opProfileFactory), "factory only");
        return true;
    }
}