// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error TransferFailed();
contract StakeContract {

  mapping (address => mapping (address => uint) ) public s_balance;

  function stake(uint256 amount, address token) external returns (bool) {
    s_balance[msg.sender][token] += amount;

    bool success =  IERC20(token).transferFrom(msg.sender, address(this), amount);
    if(!success) revert TransferFailed();

    return success;
  }
}