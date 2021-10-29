// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract TicketBookingSystem {

    address payable public seller;
    address payable public buyer;
    struct Show {
        string      titleOfShow;        //Title of the Show
        string[]    dateOfShow;         //Date of the Show
        uint32      price;              //Price
        string[]    seatNumberAndRow;   //Seat
        string      linkToSeatView;     //Link to seat view
    }
    
    modifier onlyBuyer() {
        require( msg.sender == buyer, "Only buyer can call this.");
        _;
    }
    
    modifier onlySeller() {
        require( msg.sender == seller, "Only seller can call this.");
        _;
    }
    
    /**
     * @dev Let buyer buy ticket
     * 
     */
    function buyTicket() public {
        
    }

    /**
     * @dev Store value in variable
     * @param num value to store
     */
    /*function store(uint256 num) public {
        number = num;
    }*/

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    /*function retrieve() public view returns (uint256){
        return number;
    }*/
}