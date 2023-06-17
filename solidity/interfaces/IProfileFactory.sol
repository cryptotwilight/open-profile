// SPDX-License-Identifier: APACHE 2.0
pragma solidity ^0.8.20;

// version 2
import {Avatar} from "../interfaces/IOpenProfileConsole.sol";

interface IProfileFactory {

    function createProfile(Avatar memory _avatar) external returns (address _profile);

}