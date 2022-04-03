// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  // map stakes for each stakeholder
  mapping(address => uint256) public balances;
  // set Stake event for listing on frontend
  event Stake(address addr, uint256 _stake);
  uint256 public constant threshold = 1 ether;
  // set deadline for staking period
  uint256 public deadline = block.timestamp + 72 hours;
  // initialize withdraw function open state
  bool public openForWithdraw;
  // initialize execute function call state
  bool public isExecuted;


  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Modifier to protect execute and withdraw functions
  modifier notCompleted() {
      require(!exampleExternalContract.completed(), "Operation not allowed after ExampleExternalContract is completed");
        _;
    }


  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  // function stake() public payable notCompleted{
  function stake() public payable {
    require(block.timestamp < deadline, "Staking period is over");
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

  function execute() public notCompleted {
    require(!isExecuted, "Cannot run 'execute' function more than once");
    require(block.timestamp > deadline, "Staking period is not over yet");
    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
      exampleExternalContract.complete();
    } else {
      // if the `threshold` was not met, allow everyone to call a `withdraw()` function
      openForWithdraw = true;
    }
    isExecuted = true;   
  }

  // Add a `withdraw()` function to let users withdraw their balance
  function withdraw() public notCompleted {
    require(openForWithdraw, "The contract is not opened for withdrawal yet");
    require(balances[msg.sender] > 0, "Your stake balance is zero Eth");
    uint256 amount = balances[msg.sender];
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Failed to send Ether");
    balances[msg.sender] -= amount;
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) {
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
