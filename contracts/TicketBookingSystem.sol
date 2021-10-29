// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract TicketBookingSystem {

    address payable public seller;
    address payable public buyer;
    address payable addressToTicket;
    
    modifier onlyBuyer() {
        require( msg.sender == buyer, "Only buyer can call this.");
        _;
    }
    
    modifier onlySeller() {
        require( msg.sender == seller, "Only seller can call this.");
        _;
    }
    
    /**
     * @dev Let seller add show
     * 
     */
    function addShow() public onlySeller {
        ShowTicket newTicket = new ShowTicket();
        addressToTicket = address(newTicket);
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