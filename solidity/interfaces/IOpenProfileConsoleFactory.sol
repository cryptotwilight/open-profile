// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import {Avatar} from "../interfaces/IOpenProfileConsole.sol";

// version 1

interface IOpenProfileConsoleFactory {

    function isRecognised(address _address) view external returns (bool _isRecognisedProxy);

    function createConsole(Avatar memory _avatar, address _rewardsPool,  address _directoryAddress) external returns (address _console);

}