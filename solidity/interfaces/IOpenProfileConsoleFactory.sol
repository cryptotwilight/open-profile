// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import {Avatar} from "../interfaces/IOpenProfileConsole.sol";

interface IOpenProfileConsoleFactory {

    function isRecognised(address _address) view external returns (bool _isRecognisedProxy);

    function createConsole(Avatar memory _avatar, address _rewardsPool,  address _directoryAddress) external returns (address _console);

}