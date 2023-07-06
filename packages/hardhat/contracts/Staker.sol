// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;
    mapping(address => uint256) public balances;
    event Stake(address from, uint256 amount);
    uint256 public constant threshold = 1 ether;
    uint256 public deadline = block.timestamp + 72 hours;
    bool openForWithdraw = false;
    bool executed = false;

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    modifier notCompleted() {
        require(block.timestamp > deadline, "Deadline has not expired yet.");
        // require(!executed, "Execution has already occurred.");
        _;
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

    function stake() public payable {
        require(block.timestamp < deadline);
        balances[msg.sender] = balances[msg.sender] + msg.value;
        emit Stake(msg.sender, msg.value);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
    // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance

    function execute() public notCompleted {
        if (address(this).balance >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            openForWithdraw = true;
        }

        executed = true;
    }

    function withdraw() public notCompleted {
        require(balances[msg.sender] > 0, "You have no balance remaining");
        uint256 rem = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(rem);
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) return 0;
        return deadline - block.timestamp;
    }

    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {
        this.stake{value: msg.value}();
    }
}
