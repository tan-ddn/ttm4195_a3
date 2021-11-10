// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary/blob/f6e81995da728f897cb0cd090f887eac8711ce61/contracts/BokkyPooBahsDateTimeLibrary.sol";
//import "@pipermerriam/ethereum-datetime/contracts/DateTime.sol";
//import "https://github.com/Arachnid/solidity-stringutils/blob/01e955c1d60fe8ac6c7a40f208d3b64758fae40c/src/strings.sol";

/**
 * @title ShowTicket
 * @dev Let buyers buy show tickets
 */
contract ShowTicket is ERC721 {
    using BokkyPooBahsDateTimeLibrary for uint; //Library for datetime conversion
    //using strings for *; //Library for string utils
    
    address private salesManager;
    //uint256 private tokenId;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    //string showTitle = 'Hamlet';
    //string showDate = '20/12/2021';
    //uint32 price = 1;
    //string seatPlanLink = 'www.seatplan.com';
    
    struct Show {
        string title;
        uint year;
        uint month;
        uint day;
        uint hour;
        uint min;
        uint timestamp;
        bytes maxRow;
        bytes maxSeatPerRow;
        bytes[] soldSeats;
    }
    mapping(address => Show) public show;
    
    struct Ticket {
        string title;
        uint256 timestamp;
        //bytes seatNumberAndRow;
        bytes seatRow;
        bytes seatNumber;
        uint256 price;
        string seatPlan;
    }
    mapping(uint256 => Ticket) public ticket;
    
    /**
     * @dev Convert string to uppercase
     * @param _str Value to uppercase
     */
    function strToUpper(string memory _str) internal pure returns (string memory) {
		bytes memory bStr = bytes(_str);
		bytes memory bUpper = new bytes(bStr.length);
		for (uint i = 0; i < bStr.length; i++) {
			// Lowercase character...
			if ((bStr[i] >= 0x61) && (bStr[i] <= 0x7A)) {
				// So we minus 32 to make it Uppercase
				bUpper[i] = bytes1(uint8(bStr[i]) - 32);
			} else {
				bUpper[i] = bStr[i];
			}
		}
		return string(bUpper);
	}
	
	/**
     * @dev Convert integer to string
     * @param _i Value to convert
     */
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
    
    /**
     * @dev Convert integer to datetime string (2 digits)
     * @param _int Value to conver
     */
    function uint2dtstr(uint _int) internal pure returns (string memory datetime) {
        bytes memory bdatetime = bytes(uint2str(_int));
        if (bdatetime.length == 1) {
            datetime = string(abi.encodePacked('0', uint2str(_int)));
        } else {
            datetime = uint2str(_int);
        }
    }
    
    /**
     * @dev Format nice datetime from timestamp
     * @param _timestamp Value to format
     */
    function niceDatetimeFromTimestamp(uint _timestamp) internal pure returns (string memory datetime) {
        (uint year, uint month, uint day, uint hour, uint min, uint sec) = BokkyPooBahsDateTimeLibrary.timestampToDateTime(_timestamp);
        datetime = string(abi.encodePacked(uint2dtstr(day), '/', uint2dtstr(month), '/', uint2dtstr(year), ' ', uint2dtstr(hour), ':', uint2dtstr(min)));
    }
    
    /**
     * @dev Create a new show
     * @param _title Title of the show, _day _month _year _hour _min Date and time of the show, _maxRow _maxSeatPerRow Maximum seat letter & number of the seat plan 
     */
    //constructor(string memory _title, bytes32 _date, bytes32 _time, bytes4 _maxRow, bytes4 _maxSeatPerRow) ERC721("Group 8 Show Ticket", "G8ST") {
    constructor(string memory _title, uint _day, uint _month, uint _year, uint _hour, uint _min, string memory _maxRow, uint _maxSeatPerRow) ERC721("Group 8 Show Ticket", "G8ST") {
        salesManager = msg.sender;
        //tokenId = 0;
        
        //Split _date string into array of day, month, year
        //slice memory d = _date.toSlice();
        //slice memory delim1 = "/".toSlice();
        //array memory dParts = new string[](d.count(delim1) + 1);
        //Split _time string into array of hour and minute
        //slice memory t = _time.toSlice();
        //slice memory delim2 = "/".toSlice();
        //array memory tParts = new string[](t.count(delim2) + 1);
        
        Show storage s = show[address(this)];
        s.title = _title;
        /*s.year = dParts[2];
        s.month = dParts[1];
        s.day = dParts[0];
        s.hour = tParts[0];
        s.min = dParts[1];*/
        s.year = _year;
        s.month = _month;
        s.day = _day;
        s.hour = _hour;
        s.min = _min;
        
        //s.timestamp = toTimestamp(s.year, s.month, s.day, s.hour, s.min);
        s.timestamp = BokkyPooBahsDateTimeLibrary.timestampFromDateTime(s.year, s.month, s.day, s.hour, s.min, 0);
        s.maxRow = abi.encode(strToUpper(_maxRow));
        s.maxSeatPerRow = abi.encode(_maxSeatPerRow);
    }

    /**
     * @dev Check valid letters
     * @param _letters Letters to check
     * @return validity of the letters
     */  
    function checkValidSeatLetters(bytes memory _letters) internal pure returns(bool) {
        bool validity = false;
		for (uint i = 0; i < _letters.length; i++) {
			// Check if letter is uppercase
			if ((_letters[i] >= 0x41) && (_letters[i] <= 0x5A)) {
			    validity = true;
			}
		}
		return validity;
    }

    /**
     * @dev Check valid input for seat letter and number
     * @param _seatRow, _seatNumber Seat letter and number to check
     * @return validity of the input
     */  
    function checkValidSeatInput(string memory _seatRow, uint _seatNumber) internal view returns(bool) {
        bool validity = false;
        Show storage s = show[address(this)];
        require(_seatNumber <= abi.decode(s.maxSeatPerRow, (uint)), "Seat number exceeds the theatre's capacity.");
        
        bytes memory bSeatRow = abi.encode(_seatRow);
        require(checkValidSeatLetters(bSeatRow), "Valid letter from A to Z required.");
        if (s.maxRow.length == bSeatRow.length) {         //Check example case 'BB' vs 'BA'
            uint i = 0;
            while (i < s.maxRow.length) {
                if (s.maxRow[i] > bSeatRow[i]) { 
                    validity = true;
                    i = s.maxRow.length;
                } else if (s.maxRow[i] < bSeatRow[i]) {
                    i = s.maxRow.length;
                } else if (i == s.maxRow.length - 1) {
                    validity = true;
                    i++;
                } else {
                    i++;
                }
            }
        } else if (s.maxRow.length > bSeatRow.length) {    //Check example case 'AA' vs 'Z'
            validity = true;
        }
        return validity;
    }
    
    /**
     * @dev Buy ticket
     * @param _seatRow, _seatNumber Seat letter and number to buy
     * @return the tokenId of the ticket
     */    
    function buyTicket(string memory _seatRow, uint _seatNumber) public returns(uint256) {
        //uint256 newItemId = tokenId;
        _seatRow = strToUpper(_seatRow);
        require(checkValidSeatInput(_seatRow, _seatNumber), "Seat row exceeds the theatre's capacity.");
        
        uint256 newItemId = uint256(sha256(abi.encode(_seatRow, _seatNumber)));
        
        Show storage s = show[address(this)];
        s.soldSeats.push(abi.encode(_seatRow, _seatNumber));
        
        /*Ticket storage t = ticket[newItemId];
        t.title = s.title;
        t.timestamp = s.timestamp;
        t.seatNumberAndRow = abi.encodePacked(_seatRow, _seatNumber);
        t.price = 1;
        t.seatPlan = 'www.seatplan.com';*/
        ticket[newItemId] = Ticket(s.title, s.timestamp, abi.encode(_seatRow), abi.encode(_seatNumber), 1, 'www.seatplan.com');
        
        _safeMint(msg.sender, newItemId);
        //tokenId += 1;
        return newItemId;
    }
    
    /**
     * @dev Get show information
     * @return the show title, date and time, maximum seat letter and number, sold seats
     */
    function getShowDetails() view public returns (string memory, string memory, string memory, uint, bytes[] memory) {
        
        Show storage s = show[address(this)];
        string memory maxRow = abi.decode(s.maxRow, (string));
        uint maxSeatPerRow = abi.decode(s.maxSeatPerRow, (uint));
        return (s.title, niceDatetimeFromTimestamp(s.timestamp), maxRow, maxSeatPerRow, s.soldSeats);
    }

    /**
     * @dev Get ticket information
     * @param _tokenId Unique value of the ticket
     * @return the show title, date and time, seat letter, seat number, seat price, link to seat plan
     */    
    function getTicketDetails(uint256 _tokenId) view public returns (string memory, string memory, string memory, uint, uint256, string memory) {
        
        Ticket storage t = ticket[_tokenId];
        //(string memory seatRow, uint seatNumber) = abi.decode(t.seatNumberAndRow, (string, uint));
        string memory seatRow = abi.decode(t.seatRow, (string));
        uint seatNumber = abi.decode(t.seatNumber, (uint));
        return (t.title, niceDatetimeFromTimestamp(t.timestamp), seatRow, seatNumber, t.price, t.seatPlan);
    }
    
}