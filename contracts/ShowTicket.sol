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
    //string showTitle = 'Hamlet';
    //string showDate = '12/12/2021';
    //uint32 price = 10;
    //string seatPlanLink = 'www.seatplan.com';
    
    struct Show {
        string title;
        string date;
        string time;
        uint256 numberOfSeat;
        string[] soldSeats;
    }
    mapping(uint256 => Show) public show;
    
    struct Ticket {
        string title;
        string date;
        string time;
        string seatNumberAndRow;
        uint256 price;
        string seatPlan;
    }
    mapping(uint256 => Ticket) public ticket;
    
    constructor() ERC721("Group 8 Show Ticket", "G8ST") {
        BS_address = msg.sender;
        tokenId = 0;
        Show storage s = show[0];
        s.title = 'Hamlet';
        s.date = '12/12/2021';
        s.time = '2000';
        s.numberOfSeat = 2;
    }
    
    function buyTicket(string memory _seatNumberAndRow) public returns(uint256) {
        //uint256 newItemId = tokenId;
        Show storage s = show[0];
        
        uint256 newItemId = uint256(sha256(abi.encodePacked(_seatNumberAndRow)));
        
        s.soldSeats.push(_seatNumberAndRow);
        Ticket storage t = ticket[newItemId];
        t.title = s.title;
        t.date = s.date;
        t.time = s.time;
        t.seatNumberAndRow = _seatNumberAndRow;
        t.price = 10;
        t.seatPlan = 'www.seatplan.com';
        
        _safeMint(msg.sender, newItemId);
        //tokenId += 1;
        return newItemId;
    }
    
    function getShowDetails() view public returns (string memory, string memory, string memory, uint256, string[] memory) {
        
        Show storage s = show[0];
        return (s.title, s.date, s.time, s.numberOfSeat, s.soldSeats);
    }
    
    function getTicketDetails(uint256 _tokenId) view public returns (string memory, string memory, string memory, string memory, uint256, string memory) {
        
        Ticket storage t = ticket[_tokenId];
        return (t.title, t.date, t.time, t.seatNumberAndRow, t.price, t.seatPlan);
    }
    
}