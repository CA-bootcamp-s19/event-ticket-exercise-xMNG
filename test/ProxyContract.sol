pragma solidity ^0.5.0;

import "../contracts/EventTicketsV2.sol";

contract ProxyContract {
    address public target;
    EventTicketsV2 public eventTicketInstance;

    function() external payable {}

    function setCallee(address _target) public {
        target = _target;
    }

    function proxyAddEvent(string memory description, string memory URL, uint tickets) public returns (bool) {

        // TODO: how to return bytes resultData?
        (bool success, ) = target.call(abi.encodeWithSignature("addEvent(string,string,uint256)", description, URL, tickets));

        return success;
    }

    function proxyBuyTickets(uint eventId, uint tickets, uint offer) public payable returns (bool) {
        (bool success, ) = target.call.value(offer)(abi.encodeWithSignature("buyTickets(uint256,uint256)", eventId, tickets));

        return success;
    }

    function proxyGetRefund(uint eventId) public returns (bool) {
        (bool success, ) = target.call(abi.encodeWithSignature("getRefund(uint256)", eventId));

        return success;
    }

    function proxyEndSale(uint eventId) public returns (bool) {
        (bool success, ) = target.call(abi.encodeWithSignature("endSale(uint256)", eventId));

        return success;
    }
}