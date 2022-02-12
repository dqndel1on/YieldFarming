// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
// import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./GLT.sol";
contract YieldFarm {
    using SafeMath for uint;

    string public name = "Gokyo Labs Yield Farm";
    uint priceFeed;
    uint public rate = 35;
    // AggregatorV3Interface internal priceFeed;

    GLT public glt;
    
    constructor() {
        glt = new GLT();
        // priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        priceFeed = 10000; //for vm, 1 eth = 10000 glt
    }

    function getgltBalance() view public returns(uint) {
        return IERC20(glt).balanceOf(msg.sender);
    }
    mapping(address => uint) public stakedAmount;
    mapping(address => bool) public isStaking;
    mapping(address => uint) public stakedTime;

    function stakeToken() public payable {
        stakedAmount[msg.sender] += msg.value;
        isStaking[msg.sender] = true;
        stakedTime[msg.sender] = block.timestamp;
    }

    function getStakedToken() view public returns(uint) {
        return address(this).balance;
    }

    function getStakedTokenByAddress() view public returns(uint) {
        return stakedAmount[msg.sender];
    }

    function updateRate(uint _rate) public {
        rate = _rate;
    }

    function unstakeToken() public payable {
        require(stakedAmount[msg.sender] > 0 , "Not enough balance to unstake");
        payable(msg.sender).transfer(getStakedTokenByAddress());
        stakedTime[msg.sender] = 0;
    }

    function getRewardToken() public {
        require(block.timestamp >= stakedTime[msg.sender] + 86400);
        IERC20(glt).transfer(msg.sender,getAccumulatedReward());
    } 

    function getAccumulatedReward() view public  returns(uint) {
        return getStakedPriceWithTime().mul((rate.add(36500))).div(52560000);
    }

    function getStakedPriceWithTime() view public returns(uint) {
        return (getStakeTime()).mul(priceFeed).mul(getStakedTokenByAddress());
    }

    function getStakeTime() view public returns(uint){
        return block.timestamp.sub(stakedTime[msg.sender]).div(86400);
    }

}

// Features:
// Stake Token A
// Get rewarded in Token B
// Eligible to withdraw rewards only if depositor has staked for at least 1 minute
// 35% APY
