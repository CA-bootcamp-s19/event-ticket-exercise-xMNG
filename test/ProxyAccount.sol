pragma solidity ^0.5.0;

import "./ProxyContract.sol";
import "../contracts/EventTicketsV2.sol";

contract ProxyAccount is ProxyContract {
    function deployTestContract() public returns (address) {
        return address(new EventTicketsV2());
    }
}