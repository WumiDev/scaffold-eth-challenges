pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 tokenAmount);

  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  //create a payable buyTokens() function:
  function buyTokens() public payable {
    require(msg.value > 0, "You cannot have YourToken with a zero ETH");
    uint amountOfTokens = msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, amountOfTokens);
    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
  }

  //create a withdraw() function that lets the owner withdraw ETH
   function withdraw() public onlyOwner {
    uint256 amount = address(this).balance;
    require(amount > 0, "You have a zero ETH balance");
    (bool success,) = msg.sender.call{value: amount}("");
    require(success, "Failed to send Ether");
  }

  //create a sellTokens() function:
  function sellTokens(uint256 amount) public {    
    require(amount > 0, "You have a zero ETH balance");
    uint256 tokenBalance = yourToken.balanceOf(msg.sender);
    require(tokenBalance >= amount, "Your token balance is lower than what you are attempting to sell");   
    uint256 tokenAmount = amount / tokensPerEth;
    (bool success) = yourToken.transferFrom(msg.sender, address(this), amount);
    require(success, "Failed to send Tokens");
    (success,) = msg.sender.call{value: tokenAmount}("");
    require(success, "Failed to send Tokens");
    emit SellTokens(msg.sender,amount);
  }

}
