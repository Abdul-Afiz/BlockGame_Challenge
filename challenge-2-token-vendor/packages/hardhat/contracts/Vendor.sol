pragma solidity ^0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

  YourToken public yourToken;

  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }



  // ToDo: create a payable buyTokens() function:

  function buyTokens () public payable {
   uint256 tokenAmount = msg.value * tokensPerEth;
  yourToken.transfer(msg.sender, tokenAmount);

   emit BuyTokens(msg.sender, msg.value, tokenAmount);

  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH

  function withdraw () public onlyOwner {
    uint bal = address(this).balance;
    require(bal > 0, 'there is less or no eth');

    (bool successful,) = msg.sender.call{value: bal}('');

    require(successful, 'failed to send eth');
  }

  // ToDo: create a sellTokens() function:

  function sellTokens (uint256 amount) public {
       uint256 theAmount = amount/tokensPerEth;
    yourToken.transferFrom(msg.sender, address(this), amount);
     (bool sent, bytes memory data) = msg.sender.call{value: theAmount}("");
    emit SellTokens(msg.sender, amount, theAmount);
}


}