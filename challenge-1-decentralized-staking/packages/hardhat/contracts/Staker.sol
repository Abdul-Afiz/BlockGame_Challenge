// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  mapping (address => uint256) public balances;

  uint256 public constant threshold = 1 ether;

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:


  uint256 public deadline = block.timestamp + 72 hours;

  bool public openForWithdraw;

  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  event Stake(address _sender, uint256 _amount);


  modifier checkDeadlineTime(bool timeReached) {

  uint256 remainingTime = timeLeft();

    if (timeReached) {
      require(remainingTime <= 0,'Deadline time is not reached yet');
    }else {
      require(remainingTime > 0, 'Deadline has passed');
    }
    _;
  }


  modifier notCompleted(){
    bool isCompleted = exampleExternalContract.completed();
    require(!isCompleted, 'staking has completed');
    _;
  }


  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  function stake() public payable {
      balances[msg.sender] += msg.value;
      emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function

  function execute() public notCompleted {
    uint256 contractBal = address(this).balance;

  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

    if(contractBal >= threshold) {
      exampleExternalContract.complete{value: contractBal}();
    } else {

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
        openForWithdraw = true;
    }

  }



  // Add a `withdraw()` function to let users withdraw their balance

  function withdraw() public checkDeadlineTime(true) notCompleted {

    require(openForWithdraw,"Not open for withdraw");
    
    uint256 userBal = balances[msg.sender];

    require(userBal > 0, "You don't have balance to withdraw");

    balances[msg.sender] = 0;

    (bool sent,) = msg.sender.call{value: userBal}(""); 

    require(sent, 'Failed to send to address');   
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  function timeLeft() public view returns (uint256) {

    if (block.timestamp >= deadline ) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
    

  }


  // Add the `receive()` special function that receives eth and calls stake()

  receive() external payable {
    stake();
  }
  
}
