// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

// version 2

interface IOpenDirectory {

    // profiles are automatically added to the directory on creation 

    function getProfile(address _owner) view external returns (address _profile);


}