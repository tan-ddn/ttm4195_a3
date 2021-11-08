//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
import "./TicketToken.sol";

contract TicketBookingSystem {
    
    address public owner;
    
    constructor( address _owner) public {
        owner = _owner;
    }
    
    mapping(string => TicketToken) public _tickets;
    
    mapping(string => address) public _ticketCustomers; //ticketID -> customerAdress
    
    mapping (uint256 => TicketToken.Show) public _shows; 
    
    event ShowRemoved(address removedBy, uint256 id);
    
    function doesTicketExist(string memory _ticketId) public view returns(bool){
        require(bytes(_ticketId).length > 0, "Invalid Ticket ID!");
        return _tickets[_ticketId].exists == true; //checks for the flag in the ticket struct where we set bool exists to true when adding a ticket
    }
    
    function verify(string memory _ticketId, address _customer) public returns (bool) { //verify
        require(doesTicketExist(_ticketId), "Ticket does not exist!");
        require(_customer != address(0x0), "Invalid customer Address!");
        return _ticketCustomers[_ticketId] == _customer; //checks if customer address is the same as the customer address in the addresslist
    }
    
    function refund(string memory _tickedId) public returns(bool){
        //refunds the tickets price back to the address that matches the ticketId
        _ticketCustomers[_tickedId].address.send(_tickets[_tickedId].price);
    }
    
    function validate(string memory _tickedId, uint256 _showTime) public returns(bool){
        
    }
    
    function cancelShow() public returns(bool){
        Show memory showToRemove = getShow(id);

        //TODO for loop for every seat to refund it

        delete _shows[id];

        emit ShowRemoved(msg.sender, id);

        return true;
    }
}

