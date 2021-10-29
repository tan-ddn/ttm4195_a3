// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title ShowTicket
 * @dev Let buyers buy show tickets
 */
contract ShowTicket is ERC721 {
    
    address public BS_address;
    uint256 private tokenId;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    string showTitle = 'Hamlet';
    string showDate = '12/12/2021';
    uint32 price = 10;
    uint8[4] seatNumber = [1, 2, 3, 4];
    string[3] seatRow = ['A', 'B', 'C'];
    string seatPlanLink = 'www.seatplan.com';
    
    constructor() ERC721("Group 8 Show Ticket", "G8ST") {
        BS_address = msg.sender;
        tokenId = 0;
    }
    
    function buyTicket(uint8 _seatNumber, string _seatRow) public returns(int256) {
        uint256 newItemId = tokenId;
        _safeMint(msg.sender, newItemId);
        tokenId += 1;
        return newItemId;
    }
    
}