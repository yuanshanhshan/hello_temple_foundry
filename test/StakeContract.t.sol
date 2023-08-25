// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/StakeContract.sol";

import "./mocks/MockERC20.sol";

contract StakeContractTest is Test {
    StakeContract public stakeContract;
    MockERC20 public mockERC20;
    function setUp() public {
        stakeContract = new StakeContract();
        mockERC20 = new MockERC20("Test", "Test");
    }


    function testExample() public {
      uint256 amount = 10e18;
      mockERC20.approve(address(stakeContract), amount);
      bool stakePassed = stakeContract.stake(amount, address(mockERC20));
      assertTrue(stakePassed);
    }
    
}
