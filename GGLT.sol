// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract GLT is ERC20, Ownable {
    using SafeMath for uint;
    uint maxSupply = 200000000*10**18;

   constructor() ERC20('Gokyo Labs Token','GLT') {
       _mint(msg.sender,1000000000000*10**18);
   }

   function mint(address _to, uint _amount) external onlyOwner{
       require(totalSupply()+_amount <=maxSupply,'Max Supply Exceeded!');
       _mint(_to, _amount);
   }

   function burn(uint _amount) external onlyOwner{
       _burn(msg.sender,_amount);
   }
}