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

    address public glt;
    
    constructor() {
        glt = 0xd9145CCE52D386f254917e481eB44e9943F39138;
        // priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        priceFeed = 10000; //for vm, 1 eth = 10000 glt
    }

    mapping(address => uint) public stakedAmount;
    mapping(address => bool) public isStaking;
    mapping(address => uint) public stakedTime;

    function stakeToken(uint _amount) public payable {
        IERC20(glt).transferFrom(msg.sender,address(this),_amount);
        stakedAmount[msg.sender] = _amount;
        isStaking[msg.sender] = true;
        stakedTime[msg.sender] = block.timestamp;
    }

    function getStakedToken() view public returns(uint) {
        return IERC20(glt).balanceOf(address(this));
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
        uint principal = stakedAmount[msg.sender];
        for(uint i=0;i<getStakeTime();i++){
            principal += principal.mul(rate).div(52560000);
        }
        return principal;
    }

    function getStakeTime() view public returns(uint){
        return block.timestamp.sub(stakedTime[msg.sender]).div(60);
    }

    function getBalanceOfGlt(address _add) view public returns(uint){
        return IERC20(glt).balanceOf(_add);
    }
}

// Features:
// Stake Token A
// Get rewarded in Token B
// Eligible to withdraw rewards only if depositor has staked for at least 1 minute
// 35% APY
