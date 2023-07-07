pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(
        address seller,
        uint256 amountOfETH,
        uint256 amountOfTokens
    );

    YourToken public yourToken;
    uint256 public constant tokensPerEth = 100;

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    // ToDo: create a payable buyTokens() function:
    function buyTokens() public payable {
        uint256 valueToSend = msg.value * tokensPerEth;
        yourToken.transfer(msg.sender, valueToSend);
        emit BuyTokens(msg.sender, msg.value, valueToSend);
    }

    // ToDo: create a withdraw() function that lets the owner withdraw ETH
    function withdraw() external onlyOwner {
        require(address(msg.sender) == owner());
        // require(address(this).balance >= amount, "Insufficient balance");
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to withdraw");
    }

    // ToDo: create a sellTokens(uint256 _amount) function:
    function sellTokens(uint256 _amount) public {
        // Check that the requested amount of tokens to sell is more than 0
        require(_amount > 0, "Specify an amount of token greater than zero");

        // Check that the user's token balance is enough to do the swap
        uint256 userBalance = yourToken.balanceOf(msg.sender);
        require(
            userBalance >= _amount,
            "Your balance is lower than the amount of tokens you want to sell"
        );

        // check for vendor balances
        uint256 ethBalance = address(this).balance;

        // calculate the eth amount to be transfered
        uint256 theAmount = _amount / tokensPerEth;

        require(ethBalance >= theAmount, "not enought eth");

        yourToken.transferFrom(msg.sender, address(this), _amount);

        (bool sent, ) = msg.sender.call{value: theAmount}("");
        require(sent, "failed to send eth to the other user");

        emit SellTokens(msg.sender, theAmount, _amount);
    }
}
