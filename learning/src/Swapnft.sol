// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
 

contract Swapnft is ERC721{

    uint public tokenId;

    uint public price;

    address payable public owner;

    constructor(uint _price, uint _token_id){
        tokenId = _token_id;
        price = _price;
        owner = payable(msg.sender);
    }

    function updatePrice(uint _new_price) external{
        require(msg.sender == owner);
        price = _new_price;
    }

    function remove() external{
        require(msg.sender == owner);
        selfdestruct(owner);
    }

    function purchase() external{
        require(msg.value == price);
        owner.call{value: msg.value}();
        transferFrom(owner, msg.sender, tokenId);
        selfdestruct(owner);
    }
}