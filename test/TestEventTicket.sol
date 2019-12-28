pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
// import "../contracts/EventTickets.sol";
import "../contracts/EventTicketsV2.sol";
import "../test/ProxyAccount.sol";

contract TestEventTicket {
    uint public initialBalance = 0.1 ether; // initial balance

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

        // seed buyer and other
        address(buyer).transfer(501 wei);
        // address(other).transfer(1000 wei);
    }

    // owner can addEvent
    function testAddEvent() public {
        bool result = ProxyAccount(address(owner)).proxyAddEvent("devcon hawaii 2050", "fakeURL.eth", 10);
        Assert.isTrue(result, "should be true, tx successful");

        (string memory description, string memory URL, uint totalTickets, uint sales, bool isOpen) = eventTicketInstance.events(0);
        Assert.equal(description, "devcon hawaii 2050", "description should match");
        Assert.equal(URL, "fakeURL.eth", "URL should match");
        Assert.equal(totalTickets, 10, "totalTickets should match");
        Assert.equal(sales, 0, "sales should be default");
        Assert.isTrue(isOpen, "isOpen should be true");

        uint currEventIdNum = EventTicketsV2(address(eventTicketInstance)).eventIdNumber();
        Assert.equal(currEventIdNum, 1, "eventId should be 1");
    }

    // test addEvent fails if called from nonowner
    function testAddEvenTFailsIfNotOwner() public {
        bool result = ProxyAccount(address(other)).proxyAddEvent("devcon hawaii 2050", "fakeURL.eth", 10);
        Assert.isFalse(result, "should be false, non owner tx should fail");
    }

    // test buyTickets and excess refunded
    function testBuyTickets() public {
        ProxyAccount(address(owner)).proxyAddEvent("devcon hawaii 2050", "fakeURL.eth", 10);

        bool result = ProxyAccount(address(buyer)).proxyBuyTickets(0, 5, 501);
        Assert.isTrue(result, "buy should have succeeded");

        Assert.equal(address(buyer).balance, 1 wei, "balance should be 1 wei");

    }

    // test buyTickets failure if not enough eth
    function testBuyTicketsFailNotEnoughEth() public {
        ProxyAccount(address(owner)).proxyAddEvent("devcon hawaii 2050", "fakeURL.eth", 10);

        bool result = ProxyAccount(address(buyer)).proxyBuyTickets(0, 5, 499);
        Assert.isFalse(result, "buy should have failed, insufficient eth");
    }

    // test buyTickets failure if not enough tickets remaining
    function testBuyTicketsFailureNotEnoughTicketsRemaining() public {
        ProxyAccount(address(owner)).proxyAddEvent("devcon hawaii 2050", "fakeURL.eth", 3);

        bool result = ProxyAccount(address(buyer)).proxyBuyTickets(0, 4, 400);
        Assert.isFalse(result, "buy should have failed, not enough tickets left");

    }

        // test buyTickets failure if not enough tickets remaining, multiple buys
    function testBuyTicketsFailureMultiNotEnoughTicketsRemaining() public {
        ProxyAccount(address(owner)).proxyAddEvent("devcon hawaii 2050", "fakeURL.eth", 3);

        ProxyAccount(address(buyer)).proxyBuyTickets(0, 1, 100);
        bool result = ProxyAccount(address(buyer)).proxyBuyTickets(0, 3, 300);
        Assert.isFalse(result, "buy should have failed, not enough tickets left");

    }

    // test buyTickets failure if event is not open
    function testBuyTicketsFailureIfEventIsNotOpen() public {
        bool result = ProxyAccount(address(buyer)).proxyBuyTickets(0, 5, 500);
        Assert.isFalse(result, "buy should have failed, event is not open");
    }

    // test getRefund
    function testgetRefund() public {
        ProxyAccount(address(owner)).proxyAddEvent("devcon hawaii 2050", "fakeURL.eth", 10);
    
        ProxyAccount(address(buyer)).proxyBuyTickets(0, 5, 500);

        bool result = ProxyAccount(address(buyer)).proxyGetRefund(0);
        Assert.isTrue(result, "getRefund should have refunded eth");
        Assert.equal(address(buyer).balance, 501 wei, "should be correct eth balance");
    }

    // test getRefund if no tickets bought
    function testGetRefundFailureIfNoTicketsBought() public {
        ProxyAccount(address(owner)).proxyAddEvent("devcon hawaii 2050", "fakeURL.eth", 5);

        bool result = ProxyAccount(address(buyer)).proxyGetRefund(0);
        Assert.isFalse(result, "should have failed since no tickets purchased");
    }

    // test endSale and cannot buy
    function testEndSale() public {
        ProxyAccount(address(owner)).proxyAddEvent("devcon hawaii 2050", "fakeURL.eth", 5);

        ProxyAccount(address(buyer)).proxyBuyTickets(0, 5, 500);

        bool result = ProxyAccount(address(owner)).proxyEndSale(0);
        Assert.isTrue(result, "Sale should have ended");

        (,,,, bool isOpen) = eventTicketInstance.events(0);
        Assert.isFalse(isOpen, "isOpen should be true");

        // initial balance is gone after the tx, 500 should be the actual
        Assert.equal(address(owner).balance, 500, "owner balance is incorrect");

        bool secondBuyAttempt = ProxyAccount(address(buyer)).proxyBuyTickets(0, 5, 500);
        Assert.isFalse(secondBuyAttempt, "cannot buy after saleEnd");
    }

    // test endSale failure from non-owner account
    function testEndSaleFailureIfSentFromNonOwner() public {
        ProxyAccount(address(owner)).proxyAddEvent("devcon hawaii 2050", "fakeURL.eth", 5);

        bool result = ProxyAccount(address(other)).proxyEndSale(0);
        Assert.isFalse(result, "should fail because sent by non owner");
    }
}