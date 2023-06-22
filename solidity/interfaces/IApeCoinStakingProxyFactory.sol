// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

// version 2

interface IApeCoinStakingProxyFactory {

    function isRecognisedProxy(address _address) view external returns (bool _isRecognisedProxy);

    function createProxy() external returns (address _proxy);

}