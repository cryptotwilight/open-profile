// SPDX-License-Identifier: APACHE 2.0
pragma solidity ^0.8.20;

// Version 1

interface IVersioning { 

    function getName() view external returns (string memory _name);

    function getVersion() view external returns (uint256 _version);

}