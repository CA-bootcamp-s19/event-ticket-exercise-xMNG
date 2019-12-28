pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
// import "../contracts/EventTickets.sol";
import "../contracts/EventTicketsV2.sol";
import "../test/ProxyAccount.sol";

contract TestEventTicket {
    uint public initialBalance = 1 ether; // initial balance

    ProxyAccount public owner;
    ProxyAccount public buyer;
    ProxyAccount public other;

    EventTicketsV2 public eventTicketInstance;

    function beforeEach() public {
        owner = new ProxyAccount();
        buyer = new ProxyAccount();
        other = new ProxyAccount();


        eventTicketInstance = EventTicketsV2(owner.deployTestContract());

        owner.setCallee(address(eventTicketInstance));
        buyer.setCallee(address(eventTicketInstance));
        other.setCallee(address(eventTicketInstance));
    }

    event LogOwner(address owner);
    // owner can addEvent
    function testAddEvent() public {
        // address _owner = EventTicketsV2(address(eventTicketInstance)).owner();
        address _owner = eventTicketInstance.owner();
        Assert.equal(address(owner), _owner, "owner must match");
        emit LogOwner(_owner);

        bool result = ProxyAccount(address(owner)).proxyAddEvent("devcon hawaii 2050", "fakeURL.eth", 10);
        Assert.isTrue(result, "should be true, tx successful");

        (string memory description,,,,) = eventTicketInstance.events(0);
        Assert.equal(description ,"devcon hawaii 2050", "descriptions should match");
        
        // uint currEventIdNum = EventTicketsV2(address(eventTicketContract)).eventIdNumber();
        // Assert.equal(currEventIdNum, 1, "eventId should be 1");
    }
}