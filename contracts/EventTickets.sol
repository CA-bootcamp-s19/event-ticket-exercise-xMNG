pragma solidity ^0.5.0;

    /*
        The EventTickets contract keeps track of the details and ticket sales of one event.
     */

contract EventTickets {

    /*
        Create a public state variable called owner.
        Use the appropriate keyword to create an associated getter function.
        Use the appropriate keyword to allow ether transfers.
     */
    address payable public owner;

    uint TICKET_PRICE = 100 wei;

    /*
        Create a struct called "Event".
        The struct has 6 fields: description, website (URL), totalTickets, sales, buyers, and isOpen.
        Choose the appropriate variable type for each field.
        The "buyers" field should keep track of addresses and how many tickets each buyer purchases.
    */
    struct Event {
        string description;
        string URL;
        uint totalTickets;
        uint sales;
        mapping(address => uint) buyers;
        bool isOpen;
    }

    Event myEvent;

    /*
        Define 3 logging events.
        LogBuyTickets should provide information about the purchaser and the number of tickets purchased.
        LogGetRefund should provide information about the refund requester and the number of tickets refunded.
        LogEndSale should provide infromation about the contract owner and the balance transferred to them.
    */
    event LogBuyTickets(address indexed purchaser, uint ticketsPurchased);
    event LogGetRefund(address indexed requester, uint ticketsRefunded);
    event LogEndSale(address indexed owner, uint balancedTransferred);
    
    /*
        Create a modifier that throws an error if the msg.sender is not the owner.
    */
    modifier onlyOwner() {
        require(owner == msg.sender, "msg.sender is not owner!");
        _;
    }

    /*
        Define a constructor.
        The constructor takes 3 arguments, the description, the URL and the number of tickets for sale.
        Set the owner to the creator of the contract.
        Set the appropriate myEvent details.
    */
    constructor(string memory description, string memory URL, uint totalTickets) public {
        owner = msg.sender;
        myEvent.description = description;
        myEvent.URL = URL;
        myEvent.totalTickets = totalTickets;
        myEvent.isOpen = true;
    }

    /*
        Define a function called readEvent() that returns the event details.
        This function does not modify state, add the appropriate keyword.
        The returned details should be called description, website, uint totalTickets, uint sales, bool isOpen in that order.
    */
    function readEvent()
        public
        view
        returns(string memory description, string memory website, uint totalTickets, uint sales, bool isOpen)
    {
        return (myEvent.description, myEvent.URL, myEvent.totalTickets, myEvent.sales, myEvent.isOpen);
    }

    /*
        Define a function called getBuyerTicketCount().
        This function takes 1 argument, an address and
        returns the number of tickets that address has purchased.
    */
    function getBuyerTicketCount(address _buyerAddr) public view returns(uint tickets) {
        return myEvent.buyers[_buyerAddr];
    }

    /*
        Define a function called buyTickets().
        This function allows someone to purchase tickets for the event.
        This function takes one argument, the number of tickets to be purchased.
        This function can accept Ether.
        Be sure to check:
            - That the event isOpen
            - That the transaction value is sufficient for the number of tickets purchased
            - That there are enough tickets in stock
        Then:
            - add the appropriate number of tickets to the purchasers count
            - account for the purchase in the remaining number of available tickets
            - refund any surplus value sent with the transaction
            - emit the appropriate event
    */

    function buyTickets(uint ticketsToBuy) public payable {
        require(myEvent.isOpen, "event must be open!");
        uint purchaseValue = ticketsToBuy * TICKET_PRICE; // use safeMath lib
        require(msg.value >= purchaseValue, "insufficient eth sent");
        require(ticketsToBuy <= myEvent.totalTickets - myEvent.sales, "not enough tickets remaining");

        // use safeMath lib
        myEvent.buyers[msg.sender] += ticketsToBuy;
        myEvent.sales += ticketsToBuy;

        emit LogBuyTickets(msg.sender, ticketsToBuy);

        if (msg.value > purchaseValue) { // refund excess purchase value
            msg.sender.transfer(msg.value - purchaseValue);
        }
    }

    /*
        Define a function called getRefund().
        This function allows someone to get a refund for tickets for the account they purchased from.
        TODO:
            - Check that the requester has purchased tickets.
            - Make sure the refunded tickets go back into the pool of avialable tickets.
            - Transfer the appropriate amount to the refund requester.
            - Emit the appropriate event.
    */
    function getRefund() public {
        uint refundedTickets = myEvent.buyers[msg.sender];
        require(refundedTickets >= 0, "msg.sender must have purchased tickets");

        myEvent.buyers[msg.sender] = 0;
        myEvent.sales -= refundedTickets;

        emit LogGetRefund(msg.sender, refundedTickets);
        msg.sender.transfer(refundedTickets * TICKET_PRICE);
    }

    /*
        Define a function called endSale().
        This function will close the ticket sales.
        This function can only be called by the contract owner.
        TODO:
            - close the event
            - transfer the contract balance to the owner
            - emit the appropriate event
    */
    function endSale() public onlyOwner {
        myEvent.isOpen = false;
        emit LogEndSale(owner, address(this).balance);
        owner.transfer(address(this).balance);
    }
}
