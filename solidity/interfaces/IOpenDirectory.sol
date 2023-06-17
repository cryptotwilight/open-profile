// SPDX-License-Identifier: APACHE 2.0
pragma solidity ^0.8.20;

// version 1

interface IOpenDirectory {

    // profiles are automatically added to the directory on creation 

    function getProfile(address _owner) view external returns (address _profile);


}