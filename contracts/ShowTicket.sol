// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary/blob/f6e81995da728f897cb0cd090f887eac8711ce61/contracts/BokkyPooBahsDateTimeLibrary.sol";
//import "@pipermerriam/ethereum-datetime/contracts/DateTime.sol";

/**
 * @title ShowTicket
 * @dev Let buyers buy show tickets
 */
contract ShowTicket is ERC721 {
    using BokkyPooBahsDateTimeLibrary for uint;
    
    address public BS_address;
    uint256 private tokenId;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    //string showTitle = 'Hamlet';
    //string showDate = '20/12/2021';
    //uint32 price = 10;
    //string seatPlanLink = 'www.seatplan.com';
    
    struct Show {
        string title;
        uint year;
        uint month;
        uint day;
        uint hour;
        uint min;
        uint timestamp;
        uint8 numberOfSeat;
        string[] soldSeats;
    }
    mapping(uint256 => Show) public show;
    
    struct Ticket {
        string title;
        uint256 timestamp;
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
        s.year = 2020;
        s.month = 12;
        s.day = 20;
        s.hour = 20;
        s.min = 5;
        //string memory date = s.date + ', ' + s.time;
        //let timestamp = (new Date(date)).getTime()/1000.0;
        //s.timestamp = toTimestamp(s.year, s.month, s.day, s.hour, s.min);
        s.timestamp = BokkyPooBahsDateTimeLibrary.timestampFromDateTime(s.year, s.month, s.day, s.hour, s.min, 0);
        s.numberOfSeat = 2;
    }
    
    function buyTicket(string memory _seatNumberAndRow) public returns(uint256) {
        //uint256 newItemId = tokenId;
        Show storage s = show[0];
        
        uint256 newItemId = uint256(sha256(abi.encodePacked(_seatNumberAndRow)));
        
        s.soldSeats.push(_seatNumberAndRow);
        Ticket storage t = ticket[newItemId];
        t.title = s.title;
        t.timestamp = s.timestamp;
        t.seatNumberAndRow = _seatNumberAndRow;
        t.price = 1;
        t.seatPlan = 'www.seatplan.com';
        
        _safeMint(msg.sender, newItemId);
        //tokenId += 1;
        return newItemId;
    }
    
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
    
    function datetimestr(string memory _datetime) internal pure returns (string memory datetime) {
        bytes memory bdatetime = bytes(_datetime);
        if (bdatetime.length == 1) {
            datetime = string(abi.encodePacked('0', _datetime));
        }
    }
    
    function niceDatetimeFromTimestamp(uint _timestamp) internal pure returns (string memory datetime) {
        (uint year, uint month, uint day, uint hour, uint min, uint sec) = BokkyPooBahsDateTimeLibrary.timestampToDateTime(_timestamp);
        datetime = string(abi.encodePacked(uint2str(day), '/', uint2str(month), '/', uint2str(year), ' ', uint2str(hour), ':', uint2str(min)));
    }
    
    function getShowDetails() view public returns (string memory, string memory, uint256, string[] memory) {
        
        Show storage s = show[0];
        return (s.title, niceDatetimeFromTimestamp(s.timestamp), s.numberOfSeat, s.soldSeats);
    }
    
    function getTicketDetails(uint256 _tokenId) view public returns (string memory, string memory, string memory, uint256, string memory) {
        
        Ticket storage t = ticket[_tokenId];
        return (t.title, niceDatetimeFromTimestamp(t.timestamp), t.seatNumberAndRow, t.price, t.seatPlan);
    }
    
}