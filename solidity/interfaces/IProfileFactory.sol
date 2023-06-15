// SPDX-License-Identifier: APACHE 2.0
pragma solidity ^0.8.20;


interface IProfileFactory {

    function createProfile(address _owner, string memory name) external returns (address _profile);

}