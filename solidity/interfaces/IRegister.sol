// SPDX-License-Identifier: APACHE 2.0
pragma solidity ^0.8.20;

interface IRegister {

    function getAddress(string memory _name) view external returns (address _address);

    function getName(address _address) view external returns (string memory _name);

}