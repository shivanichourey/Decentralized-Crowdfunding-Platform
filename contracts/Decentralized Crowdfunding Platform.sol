// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public owner;
    uint public goalAmount;
    uint public deadline;
    uint public totalRaised;
    bool public goalReached;

    mapping(address => uint) public contributions;

    constructor(uint _goalAmount, uint _durationInDays) {
        owner = msg.sender;
        goalAmount = _goalAmount;
        deadline = block.timestamp + (_durationInDays * 1 days);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier campaignActive() {
        require(block.timestamp < deadline, "Campaign ended");
        _;
    }

    modifier campaignEnded() {
        require(block.timestamp >= deadline, "Campaign still active");
        _;
    }

    function contribute() public payable campaignActive {
        require(msg.value > 0, "Contribution must be greater than 0");
        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;
    }

    function withdraw() public onlyOwner campaignEnded {
        require(totalRaised >= goalAmount, "Funding goal not met");
        goalReached = true;
        payable(owner).transfer(address(this).balance);
    }

    function refund() public campaignEnded {
        require(totalRaised < goalAmount, "Goal was reached; no refunds");
        uint amount = contributions[msg.sender];
        require(amount > 0, "No contribution to refund");
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}

