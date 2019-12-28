pragma solidity ^0.5.0;

import "../contracts/EventTicketsV2.sol";

contract ProxyContract {
    address public target;
    EventTicketsV2 public eventTicketInstance;

    function() external payable {}

    function setCallee(address _target) public {
        target = _target;
    }

    event LogProxyAddEventCalled(address owner, string description, string URL, uint tickets);
    event LogOutcome(bool, bytes);

    function proxyAddEvent(string memory description, string memory URL, uint tickets) public returns (bool) {

        emit LogProxyAddEventCalled(address(this), description, URL, tickets);

        // TODO: this call is failing
        (bool success, bytes memory resultData) = target.call(abi.encodeWithSignature("addEvent(string,string,uint256)", description, URL, tickets));

        emit LogOutcome(success, resultData);

        return success;
    }
}